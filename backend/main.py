from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
from dotenv import load_dotenv
from openai import OpenAI
from supabase import create_client, Client
from typing import Optional, List
import json

# Load environment variables
load_dotenv()

# Initialize FastAPI app
app = FastAPI(title="SMS Campaign Manager API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins like ["https://yourdomain.com"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Supabase client
supabase: Client = create_client(
    os.getenv("SUPABASE_URL"),
    os.getenv("SUPABASE_KEY")
)

# Initialize DeepSeek client (using OpenAI SDK)
deepseek_client = OpenAI(
    api_key=os.getenv("DEEPSEEK_API_KEY"),
    base_url=os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com")
)

# Request/Response Models
class GenerateSMSRequest(BaseModel):
    prompt: str
    link: Optional[str] = None

class GenerateSMSResponse(BaseModel):
    content: str
    character_count: int

class ScheduleSMSRequest(BaseModel):
    prompt: str
    link: Optional[str] = None
    content: str
    scheduled_at: str
    contact_ids: Optional[List[str]] = None  # If provided, send to specific contacts

class ScheduleSMSResponse(BaseModel):
    campaign_id: str
    status: str
    message: str

class ContactRequest(BaseModel):
    name: Optional[str] = None
    phone_number: str
    tags: Optional[List[str]] = None

class ContactResponse(BaseModel):
    id: str
    name: Optional[str]
    phone_number: str
    tags: Optional[List[str]]
    created_at: str

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}

# ==================== SMS Generation ====================

@app.post("/generate-sms", response_model=GenerateSMSResponse)
async def generate_sms(request: GenerateSMSRequest):
    """
    Generate SMS content using DeepSeek API
    Takes a prompt and optional URL, returns generated SMS (max 1500 chars)
    """
    try:
        # Build the message for DeepSeek
        user_message = f"""You are a professional SMS marketing writer. 
        Generate a professional, engaging SMS message (maximum 1500 characters) in Traditional Chinese.
        
        User Prompt: {request.prompt}
        """
        
        if request.link:
            user_message += f"\nLink to include: {request.link}"
        
        user_message += "\n\nRespond with ONLY the SMS content, no explanations."
        
        # Call DeepSeek API
        response = deepseek_client.chat.completions.create(
            model="deepseek-chat",
            messages=[
                {"role": "system", "content": "You are a professional SMS marketing copywriter."},
                {"role": "user", "content": user_message}
            ],
            temperature=0.7,
            max_tokens=500
        )
        
        generated_content = response.choices[0].message.content.strip()
        
        # Ensure content doesn't exceed 1500 characters
        if len(generated_content) > 1500:
            generated_content = generated_content[:1500]
        
        return GenerateSMSResponse(
            content=generated_content,
            character_count=len(generated_content)
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating SMS: {str(e)}")

# ==================== Campaign Management ====================

@app.post("/schedule-sms", response_model=ScheduleSMSResponse)
async def schedule_sms(request: ScheduleSMSRequest):
    """
    Save an SMS campaign to Supabase and schedule it for sending
    Creates a campaign record and optionally associates it with specific contacts
    """
    try:
        # Insert campaign into sms_campaigns table
        campaign_data = {
            "prompt": request.prompt,
            "link": request.link,
            "content": request.content,
            "status": "scheduled",
            "scheduled_at": request.scheduled_at
        }
        
        response = supabase.table("sms_campaigns").insert(campaign_data).execute()
        campaign_id = response.data[0]["id"]
        
        # If specific contacts are provided, create message logs for them
        if request.contact_ids:
            message_logs = [
                {
                    "campaign_id": campaign_id,
                    "contact_id": contact_id,
                    "status": "pending"
                }
                for contact_id in request.contact_ids
            ]
            supabase.table("message_logs").insert(message_logs).execute()
        
        return ScheduleSMSResponse(
            campaign_id=campaign_id,
            status="scheduled",
            message="Campaign scheduled successfully"
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error scheduling SMS: {str(e)}")

@app.get("/process-queue")
async def process_queue():
    """
    Process the queue: find scheduled messages and send them
    This should be called by a cron job periodically
    """
    try:
        # Get all campaigns with status 'scheduled' and scheduled_at <= now
        response = supabase.table("sms_campaigns").select("*").eq("status", "scheduled").execute()
        
        campaigns_to_send = []
        for campaign in response.data:
            from datetime import datetime, timezone
            scheduled_time = datetime.fromisoformat(campaign["scheduled_at"].replace('Z', '+00:00'))
            current_time = datetime.now(timezone.utc)
            
            if scheduled_time <= current_time:
                campaigns_to_send.append(campaign)
        
        if not campaigns_to_send:
            return {"status": "success", "message": "No campaigns to send", "count": 0}
        
        # For each campaign, get all associated contacts
        sent_count = 0
        for campaign in campaigns_to_send:
            try:
                # Get message logs for this campaign
                logs_response = supabase.table("message_logs").select(
                    "*, contacts(*)"
                ).eq("campaign_id", campaign["id"]).eq("status", "pending").execute()
                
                for log in logs_response.data:
                    contact = log["contacts"]
                    phone_number = contact["phone_number"]
                    
                    # Placeholder for Twilio API call
                    print(f"[PLACEHOLDER] Sending SMS to {phone_number}: {campaign['content'][:100]}...")
                    
                    # In production, replace this with:
                    # try:
                    #     twilio_client.messages.create(
                    #         body=campaign['content'],
                    #         from_=os.getenv("TWILIO_PHONE_NUMBER"),
                    #         to=phone_number
                    #     )
                    #     status = "sent"
                    # except Exception as e:
                    #     status = "failed"
                    
                    # Update message log status
                    supabase.table("message_logs").update({
                        "status": "sent" if True else "failed",
                        "sent_at": "now()" if True else None
                    }).eq("id", log["id"]).execute()
                    
                    sent_count += 1
                
                # Update campaign status
                supabase.table("sms_campaigns").update({
                    "status": "sent"
                }).eq("id", campaign["id"]).execute()
            
            except Exception as e:
                print(f"Error sending campaign {campaign['id']}: {str(e)}")
                supabase.table("sms_campaigns").update({
                    "status": "failed"
                }).eq("id", campaign["id"]).execute()
        
        return {
            "status": "success",
            "message": f"Processed {len(campaigns_to_send)} campaigns",
            "sent_count": sent_count
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing queue: {str(e)}")

# ==================== Contact Management ====================

@app.post("/contacts", response_model=ContactResponse)
async def create_contact(contact: ContactRequest):
    """Create a new contact"""
    try:
        response = supabase.table("contacts").insert({
            "name": contact.name,
            "phone_number": contact.phone_number,
            "tags": contact.tags
        }).execute()
        
        data = response.data[0]
        return ContactResponse(
            id=data["id"],
            name=data["name"],
            phone_number=data["phone_number"],
            tags=data["tags"],
            created_at=data["created_at"]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating contact: {str(e)}")

@app.get("/contacts")
async def list_contacts():
    """Get all contacts"""
    try:
        response = supabase.table("contacts").select("*").execute()
        return response.data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching contacts: {str(e)}")

@app.get("/contacts/{contact_id}")
async def get_contact(contact_id: str):
    """Get a specific contact"""
    try:
        response = supabase.table("contacts").select("*").eq("id", contact_id).execute()
        if not response.data:
            raise HTTPException(status_code=404, detail="Contact not found")
        return response.data[0]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching contact: {str(e)}")

@app.delete("/contacts/{contact_id}")
async def delete_contact(contact_id: str):
    """Delete a contact"""
    try:
        supabase.table("contacts").delete().eq("id", contact_id).execute()
        return {"message": "Contact deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting contact: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host=os.getenv("BACKEND_HOST", "127.0.0.1"),
        port=int(os.getenv("BACKEND_PORT", 8000))
    )
