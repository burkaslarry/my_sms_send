# SMS Campaign Backend (Python FastAPI)

## Setup Instructions

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Configure Environment Variables
Copy `.env.example` to `.env` and fill in your credentials:
```bash
cp .env.example .env
```

Then edit `.env` with your actual values:
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_KEY` - Your Supabase anon key
- `DEEPSEEK_API_KEY` - Your DeepSeek API key
- `TWILIO_ACCOUNT_SID` - Twilio SID (optional for now)
- `TWILIO_AUTH_TOKEN` - Twilio token (optional for now)
- `TWILIO_PHONE_NUMBER` - Your Twilio number (optional for now)

### 3. Run the Backend Locally
```bash
python main.py
```

The API will be available at `http://localhost:8000`

API Documentation (Swagger UI) will be at `http://localhost:8000/docs`

## API Endpoints

### SMS Generation
**POST** `/generate-sms`
- Request: `{ "prompt": "string", "link": "string (optional)" }`
- Response: `{ "content": "string", "character_count": int }`

### Campaign Management
**POST** `/schedule-sms`
- Request: `{ "prompt": "string", "link": "string (optional)", "content": "string", "scheduled_at": "ISO8601", "contact_ids": ["uuid"] }`
- Response: `{ "campaign_id": "string", "status": "string", "message": "string" }`

**GET** `/process-queue`
- Processes all scheduled campaigns that are ready to send
- Called by cron job

### Contact Management
**POST** `/contacts`
- Create a new contact

**GET** `/contacts`
- List all contacts

**GET** `/contacts/{contact_id}`
- Get a specific contact

**DELETE** `/contacts/{contact_id}`
- Delete a contact

## Cron Job Setup

### Using GitHub Actions (Recommended)
See `.github/workflows/sms-cron.yml` for the workflow configuration.

### Using External Cron Service
You can also use services like:
- Vercel Crons
- EasyCron
- AWS EventBridge
- Render Background Jobs

Example command:
```bash
python cron_worker.py
```

Or call the endpoint directly:
```bash
curl https://your-backend-url/process-queue
```

## Deployment to Render

1. Create a new "Web Service" on Render.com
2. Connect your GitHub repository
3. Set the following environment variables in Render:
   - All values from your `.env` file
4. Set the start command: `uvicorn main:app --host 0.0.0.0 --port 8000`
5. Deploy!

For scheduled jobs on Render, create a separate "Background Job" service and point it to `cron_worker.py`

## Notes

- SMS sending is currently a placeholder (prints to console)
- To enable actual Twilio sending, uncomment the Twilio code in the `/process-queue` endpoint
- Messages are limited to 1500 characters by DeepSeek API constraints
