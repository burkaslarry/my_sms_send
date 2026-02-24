# SMS Campaign Manager - Step-by-Step Setup Guide

This guide walks you through the complete setup process for the SMS Campaign Manager application.

## 📋 Prerequisites

Before you begin, make sure you have:
- **Node.js** 16+ ([download](https://nodejs.org/))
- **Python** 3.8+ ([download](https://www.python.org/))
- **Git** ([download](https://git-scm.com/))
- A **GitHub account** (for GitHub Actions)
- A **Supabase account** (free tier available at [supabase.com](https://supabase.com))
- A **DeepSeek API key** (from [platform.deepseek.com](https://platform.deepseek.com))

## 🎯 Project Structure Created

```
my_sms_send/
├── backend/                          # Python FastAPI server
│   ├── main.py                      # Main API application
│   ├── cron_worker.py               # Scheduled task runner
│   ├── requirements.txt              # Python dependencies
│   ├── .env.example                 # Environment template
│   └── README.md                    # Backend documentation
│
├── frontend/                         # Next.js React app
│   ├── app/
│   │   ├── contacts/page.tsx        # Contacts management
│   │   ├── campaign/page.tsx        # Campaign creation
│   │   ├── layout.tsx               # Root layout
│   │   └── page.tsx                 # Home page
│   ├── components/Sidebar.tsx       # Navigation component
│   ├── lib/                         # Utility functions
│   │   ├── api.ts                   # API client
│   │   ├── config.ts                # Configuration
│   │   └── supabase.ts              # Supabase client
│   ├── styles/globals.css           # Global styles
│   ├── package.json                 # Node dependencies
│   ├── tsconfig.json                # TypeScript config
│   ├── tailwind.config.js           # Tailwind CSS config
│   ├── .env.example                 # Environment template
│   └── README.md                    # Frontend documentation
│
├── supabase/
│   └── schema.sql                   # Database schema
│
├── .github/workflows/
│   └── sms-cron.yml                 # GitHub Actions workflow
│
├── .gitignore                       # Git ignore rules
└── README.md                        # Main documentation
```

## 🔧 Step 1: Set Up Supabase Database

1. **Create Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Click "New Project"
   - Fill in project name and password
   - Wait for project to initialize (2-3 minutes)

2. **Get Your Credentials**
   - Project Settings → API
   - Copy `Project URL` (SUPABASE_URL)
   - Copy `anon public` key (SUPABASE_KEY)

3. **Create Database Schema**
   - Go to SQL Editor in Supabase Dashboard
   - Create a new query
   - Copy the entire content from `supabase/schema.sql`
   - Paste it into Supabase SQL Editor
   - Click "RUN" to execute
   - You should see the message "Success. No rows returned"

✅ **Check**: You should see 3 tables: `contacts`, `sms_campaigns`, `message_logs`

## 🔧 Step 2: Set Up Backend (Python FastAPI)

### Install and Configure

```bash
# Navigate to backend folder
cd backend

# Copy environment template
cp .env.example .env

# Edit .env with your editor
nano .env  # or use your favorite editor
```

### Fill in the .env file:

```ini
# Required - from Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-supabase-anon-key

# Required - from DeepSeek
DEEPSEEK_API_KEY=your-deepseek-api-key
DEEPSEEK_BASE_URL=https://api.deepseek.com

# Optional (for real SMS sending later)
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_PHONE_NUMBER=+1234567890

# Backend settings
BACKEND_PORT=8500
BACKEND_HOST=127.0.0.1
```

### Install Dependencies and Run

```bash
# Install Python and dependencies
pip install -r requirements.txt

# Run the backend server
python main.py
```

✅ **Check**: You should see:
```
INFO:     Uvicorn running on http://127.0.0.1:8000
```

### Test the API

Open http://localhost:8000/docs in your browser. You should see the interactive API documentation.

### Stop the server

Press `Ctrl+C` in your terminal to stop the backend. Keep it stopped for now - you'll restart it when setting up the frontend.

## 🔧 Step 3: Set Up Frontend (Next.js)

### Install and Configure

Open a **new terminal window** and navigate to the frontend:

```bash
# Navigate to frontend folder
cd frontend

# Copy environment template
cp .env.example .env.local

# Edit .env.local with your editor
nano .env.local  # or use your favorite editor
```

### Fill in the .env.local file:

```ini
# Your backend API URL
NEXT_PUBLIC_API_URL=http://localhost:8000

# From Supabase (same credentials as backend)
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
```

### Install Dependencies and Run

```bash
# Install Node dependencies
npm install

# Run the development server
npm run dev
```

✅ **Check**: You should see:
```
> Local:        http://localhost:3000
```

## 🧪 Testing Locally

With both servers running:

1. **Frontend**: Open http://localhost:3000 in your browser
2. **Backend**: API docs at http://localhost:8000/docs
3. **Add a Contact**:
   - Click "Contacts" in the sidebar
   - Click "Add Contact"
   - Enter a phone number (can be fake: +1234567890)
   - Click "Add Contact"

4. **Generate an SMS**:
   - Click "New Campaign"
   - Enter a prompt: "Write a greeting message"
   - Click "Generate with DeepSeek"
   - Wait for the AI to generate content

5. **Schedule an SMS**:
   - Set a future date/time (e.g., 1 minute from now)
   - Click "Confirm Schedule"

## 🌐 Deployment

### Deploy Backend to Render.com (Free)

1. **Create Render Account**
   - Go to [render.com](https://render.com)
   - Sign up with GitHub

2. **Deploy Backend**
   - Click "New +"
   - Select "Web Service"
   - Connect your GitHub repository
   - Fill in:
     - Name: `sms-backend`
     - Environment: `Python 3`
     - Start Command: `uvicorn main:app --host 0.0.0.0`
     - Root Directory: `backend`
   
3. **Set Environment Variables**
   - Go to "Environment Variables"
   - Add all your `.env` values from the backend

4. **Deploy**
   - Click "Deploy Service"
   - Wait for it to build and deploy (3-5 minutes)
   - Get your URL: `https://sms-backend-xxx.onrender.com`

### Deploy Frontend to Vercel (Free)

1. **Create Vercel Account**
   - Go to [vercel.com](https://vercel.com)
   - Sign up with GitHub

2. **Deploy Frontend**
   - Import your GitHub repository
   - Select "Next.js" framework
   - Root Directory: `frontend`

3. **Set Environment Variables**
   - From your Render deployment, get the backend URL
   - Add to Vercel:
     ```
     NEXT_PUBLIC_API_URL=https://your-sms-backend-xxx.onrender.com
     NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
     NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-key
     ```

4. **Deploy**
   - Click "Deploy"
   - Your frontend URL: `https://your-project-name.vercel.app`

## ⏰ Set Up Automatic SMS Sending

### Option 1: GitHub Actions (Recommended)

1. **Add Backend URL Secret**
   - Go to your GitHub repo
   - Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `BACKEND_URL`
   - Value: Your Render backend URL (e.g., `https://sms-backend-xxx.onrender.com`)

2. **Workflow is Already Set**
   - The file `.github/workflows/sms-cron.yml` is already included
   - It runs every 10 minutes automatically
   - It calls your backend's `/process-queue` endpoint

3. **Check It's Working**
   - Go to your repo → Actions
   - You should see "SMS Queue Processor" runs every 10 minutes

### Option 2: Render Background Job

If you want SMS to send more reliably without GitHub Actions:

1. On Render, create a "Background Job"
2. Same configuration as the Web Service
3. Set start command: `python cron_worker.py`
4. Set timing to check every 10 minutes

## 🔑 API Endpoints Reference

### Generate SMS Content
```bash
curl -X POST http://localhost:8000/generate-sms \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Write a promotional message about our new product",
    "link": "https://example.com/new-product"
  }'
```

### Schedule SMS Campaign
```bash
curl -X POST http://localhost:8000/schedule-sms \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Summer Sale Announcement",
    "content": "50% off this summer!",
    "scheduled_at": "2026-03-01T10:00:00Z",
    "contact_ids": ["uuid1", "uuid2"]
  }'
```

### Manually Trigger Processing
```bash
curl http://localhost:8000/process-queue
```

## 📱 Enable Real SMS Sending (Optional)

Currently SMS sending uses a placeholder. To enable real Twilio sending:

1. **Get Twilio Account**
   - Sign up at [twilio.com](https://twilio.com)
   - Get your Account SID, Auth Token, and Phone Number

2. **Add to Environment**
   - Update `.env` in backend with Twilio credentials
   - Redeploy backend

3. **Uncomment Code**
   - In `backend/main.py`, find the `/process-queue` endpoint
   - Uncomment the Twilio sending section
   - Comment out the placeholder print statement
   - Redeploy

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Connection refused" on frontend | Make sure backend is running on port 8000 |
| DeepSeek API returns error | Check API key is correct and has credits |
| SMS not generating | Check internet connection and API rate limits |
| Scheduled SMS not sending | Check cron job logs in GitHub Actions → Workflows |
| Supabase tables not found | Make sure schema.sql was executed in SQL Editor |

## 📞 Getting Help

- **DeepSeek API Issues**: https://platform.deepseek.com
- **Supabase Help**: https://supabase.com/docs
- **FastAPI Docs**: https://fastapi.tiangolo.com
- **Next.js Docs**: https://nextjs.org/docs
- **Render Deployment**: https://render.com/docs

## ✨ Next Steps

After setup:

1. Add more contacts through the frontend
2. Test SMS generation with different prompts
3. Schedule campaigns for future delivery
4. Monitor message logs in Supabase dashboard
5. Customize the SMS content generation prompt
6. Add your own branding/colors to the frontend

---

**Congratulations!** Your SMS Campaign Manager is now set up! 🎉
