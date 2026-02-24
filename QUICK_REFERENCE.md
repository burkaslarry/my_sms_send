# Quick Reference - Commands & Files

## 📁 What Was Created

### Database
- `supabase/schema.sql` - Database schema with 3 tables (contacts, sms_campaigns, message_logs)

### Backend (Python FastAPI)
- `backend/main.py` - FastAPI server with all endpoints
- `backend/cron_worker.py` - Script to process scheduled SMS
- `backend/requirements.txt` - Python dependencies
- `backend/.env.example` - Environment template
- `backend/README.md` - Backend documentation

### Frontend (Next.js + Tailwind + React)
- `frontend/app/` - Next.js app directory
  - `contacts/page.tsx` - Contact management
  - `campaign/page.tsx` - Campaign creation
  - `layout.tsx` - Root layout
  - `page.tsx` - Home page
- `frontend/components/Sidebar.tsx` - Navigation component
- `frontend/lib/` - Utility files
  - `api.ts` - Axios API client
  - `config.ts` - Configuration
  - `supabase.ts` - Supabase client
- `frontend/styles/globals.css` - Global styles
- `frontend/package.json` - Node dependencies
- `frontend/tailwind.config.js` - Tailwind configuration
- `frontend/tsconfig.json` - TypeScript configuration
- `frontend/.env.example` - Environment template
- `frontend/README.md` - Frontend documentation

### Automation
- `.github/workflows/sms-cron.yml` - GitHub Actions that runs every 10 minutes

### Configuration
- `.gitignore` - Configured for Python + Node.js projects
- `README.md` - Main documentation
- `SETUP_GUIDE.md` - Step-by-step setup instructions

---

## 🚀 Quick Commands

### Initialize Backend
```bash
cd backend
cp .env.example .env
# Edit .env with your credentials
pip install -r requirements.txt
python main.py
```

### Initialize Frontend
```bash
cd frontend
cp .env.example .env.local
# Edit .env.local with your credentials
npm install
npm run dev
```

### Test API
```bash
# Health check
curl http://localhost:8000/health

# Generate SMS
curl -X POST http://localhost:8000/generate-sms \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Test message"}'

# Swagger UI documentation
open http://localhost:8000/docs
```

### Visit Applications
```
Frontend:  http://localhost:3000
Backend:   http://localhost:8000
API Docs:  http://localhost:8000/docs
```

---

## 🔐 Required API Keys

Get these from:

| Service | Where to Get | What It's For |
|---------|-------------|--------------|
| Supabase URL | supabase.com → Project Settings | Database server |
| Supabase Key | supabase.com → Project Settings | Database access |
| DeepSeek API Key | platform.deepseek.com → API Keys | AI SMS generation |
| Twilio SID | twilio.com → Account Info | SMS sending (optional) |
| Twilio Token | twilio.com → Account Info | SMS sending (optional) |
| Twilio Number | twilio.com → Phone Numbers | SMS sending (optional) |

---

## 📊 Database Schema

### contacts
```sql
id (UUID, primary key)
name (TEXT)
phone_number (TEXT, required)
tags (TEXT[])
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

### sms_campaigns
```sql
id (UUID, primary key)
prompt (TEXT, required)
link (TEXT)
content (TEXT, up to 1500 chars)
status (draft, scheduled, sent, failed)
scheduled_at (TIMESTAMP)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

### message_logs
```sql
id (UUID, primary key)
campaign_id (UUID, foreign key)
contact_id (UUID, foreign key)
status (pending, sent, failed)
sent_at (TIMESTAMP)
error_message (TEXT)
created_at (TIMESTAMP)
```

---

## 🔄 Data Flow

1. **Frontend** (Next.js) → User inputs prompt and link
2. **API Call** → POST `/generate-sms` to backend
3. **Backend** → Calls DeepSeek API for AI-generated content
4. **Response** → Generated SMS returned to frontend
5. **User Review** → Edit content in frontend
6. **Schedule** → POST `/schedule-sms` with campaign details
7. **Database** → Supabase stores campaign and contacts
8. **Cron Job** → Every 10 min, calls `/process-queue`
9. **Sending** → Backend sends SMS via Twilio (placeholder for now)
10. **Logging** → message_logs table tracks delivery

---

## 🌐 Environments

### Development
```
Backend:  http://localhost:8000
Frontend: http://localhost:3000
Database: Supabase cloud
```

### Production (Render + Vercel)
```
Backend:  https://your-backend.onrender.com
Frontend: https://your-frontend.vercel.app
Database: Supabase cloud
```

---

## 📋 Checklist

- [ ] Python 3.8+ installed
- [ ] Node.js 16+ installed
- [ ] Supabase project created
- [ ] Supabase schema imported
- [ ] DeepSeek API key obtained
- [ ] Backend .env configured
- [ ] Frontend .env.local configured
- [ ] Backend running on 8000
- [ ] Frontend running on 3000
- [ ] Can access http://localhost:3000
- [ ] Can access http://localhost:8000/docs
- [ ] Added contact in frontend
- [ ] Generated SMS with DeepSeek
- [ ] Backend deployed to Render
- [ ] Frontend deployed to Vercel
- [ ] GitHub Actions secrets configured
- [ ] Verified cron job running

---

## 🎯 Feature List

### Backend API Endpoints
- ✅ POST `/generate-sms` - AI SMS generation
- ✅ POST `/schedule-sms` - Schedule campaigns
- ✅ GET `/process-queue` - Process scheduled messages
- ✅ GET `/contacts` - List contacts
- ✅ POST `/contacts` - Create contact
- ✅ GET `/contacts/{id}` - Get contact
- ✅ DELETE `/contacts/{id}` - Delete contact
- ✅ GET `/health` - Health check

### Frontend Pages
- ✅ `/` - Home (redirects to contacts)
- ✅ `/contacts` - Contact management
- ✅ `/campaign` - Campaign creation

### Frontend Features
- ✅ Responsive sidebar navigation
- ✅ Add/view/delete contacts
- ✅ SMS generation with AI
- ✅ Message preview and editing
- ✅ Contact selection for targeting
- ✅ Date/time scheduling
- ✅ Toast notifications
- ✅ Mobile-friendly design

### Backend Features
- ✅ DeepSeek integration
- ✅ Supabase integration
- ✅ Campaign scheduling
- ✅ Message logging
- ✅ Cron job support
- ✅ CORS enabled
- ✅ Auto documentation (Swagger)
- ✅ Error handling

---

## 📖 Documentation Files

- `README.md` - Main project overview
- `SETUP_GUIDE.md` - Step-by-step setup instructions
- `backend/README.md` - Backend-specific documentation
- `frontend/README.md` - Frontend-specific documentation
- This file - Quick reference

---

## 🆘 Common Issues

**Backend won't start:**
- Check Python version: `python --version` (need 3.8+)
- Check all dependencies installed: `pip install -r requirements.txt`
- Check .env file exists with correct credentials

**Frontend won't run:**
- Check Node version: `node --version` (need 16+)
- Check npm installed: `npm --version`
- Delete `node_modules` and `package-lock.json`, then run `npm install` again

**SMS not generating:**
- Check DeepSeek API key is valid
- Check internet connection
- Check backend logs for errors

**Deployed app not working:**
- Check environment variables in Render/Vercel
- Check backend URL in frontend .env
- Check Supabase credentials are correct

---

## 📞 Support Links

- Next.js: https://nextjs.org/docs
- FastAPI: https://fastapi.tiangolo.com
- Supabase: https://supabase.com/docs
- DeepSeek: https://platform.deepseek.com/docs
- Tailwind CSS: https://tailwindcss.com/docs
- Render: https://render.com/docs
- Vercel: https://vercel.com/docs
