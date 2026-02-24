# Project Architecture Overview

## 📐 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Web Browsers                            │
│                    (Chrome, Safari, etc)                        │
└────────────────────────┬──────────────────────────────────────┘
                         │
                    HTTP/HTTPS (Port 3000)
                         │
        ┌────────────────▼────────────────┐
        │                                 │
        │    Frontend (Next.js + React)   │
        │    http://localhost:3500        │
        │                                 │
        │  - Contacts Page               │
        │  - Campaign Page               │
        │  - Sidebar Navigation          │
        │                                 │
        └────────────────┬────────────────┘
                         │
                    REST API (Port 8500)
                    HTTP/HTTPS
                         │
        ┌────────────────▼────────────────┐
        │                                 │
        │ Backend (Python FastAPI)       │
        │ http://localhost:8500          │
        │                                 │
        │ Routes:                        │
        │ - POST /generate-sms           │
        │ - POST /schedule-sms           │
        │ - GET /process-queue           │
        │ - GET/POST/DELETE /contacts    │
        │                                 │
        └────┬──────────┬──────────────┬──┘
             │          │              │
        API Call    API Call      Supabase
             │          │         SDK Call
             │          │              │
        ┌────▼──┐  ┌────▼────┐  ┌─────▼──────┐
        │DeepSeek   │Twilio   │  │  Supabase  │
        │(AI SMS)   │(SMS API)│  │ (Database) │
        │           │         │  │            │
        │           │         │  │ Tables:    │
        │           │         │  │ -contacts  │
        │           │         │  │ -campaigns │
        │           │         │  │ -logs      │
        └───────────┴─────────┴──┴────────────┘
```

## 📦 Backend Components

### main.py
**Purpose**: Main FastAPI application
**Key Functions**:
- Initialize FastAPI app and middleware
- Define all REST API endpoints
- Handle request/response processing
- Integrate with DeepSeek, Supabase, and Twilio

**Key Endpoints**:
```
POST /generate-sms          - Generate SMS via DeepSeek
POST /schedule-sms          - Save campaign to Supabase
GET /process-queue          - Send scheduled SMS
GET/POST/DELETE /contacts   - Contact management
GET /health                 - Health check
```

### cron_worker.py
**Purpose**: Standalone script for scheduled task execution
**Key Function**:
- Calls `/process-queue` endpoint
- Can be run via GitHub Actions, Render background job, or external cron service

### requirements.txt
**Purpose**: Python package list
**Contains**:
- fastapi - Web framework
- uvicorn - ASGI server
- supabase - Database SDK
- openai - DeepSeek API client
- python-dotenv - Environment variables
- twilio - SMS service (optional)

### .env.example
**Purpose**: Environment variables template
**Variables**:
- Supabase credentials
- DeepSeek API key
- Twilio credentials (optional)
- Server configuration

## 📱 Frontend Components

### app/layout.tsx
**Purpose**: Root layout wrapper
**Contains**:
- HTML head configuration
- Toast notification system
- Global body styling

### app/page.tsx
**Purpose**: Home page
**Function**: Redirects to `/contacts` on load

### app/contacts/page.tsx
**Purpose**: Contact management page
**Features**:
- Display contact list in table
- Add new contacts via form
- Delete contacts
- View tags and phone numbers
- API integration with backend

### app/campaign/page.tsx
**Purpose**: SMS campaign creation page
**Features**:
- Input prompt and link
- Generate SMS via backend
- Edit generated content
- Select recipient contacts
- Set scheduled time
- Submit campaign

### components/Sidebar.tsx
**Purpose**: Navigation component
**Features**:
- Links to Contacts and Campaign pages
- Mobile-responsive menu
- Branding and title

### lib/api.ts
**Purpose**: Axios API client configuration
**Functions**:
- Configure base URL
- Set default headers
- Handle errors
- Axios interceptors

### lib/config.ts
**Purpose**: Configuration constants
**Contains**:
- API_URL
- SUPABASE_URL
- SUPABASE_ANON_KEY

### lib/supabase.ts
**Purpose**: Supabase client initialization
**Functions**:
- Initialize Supabase client
- Export for direct database access

### styles/globals.css
**Purpose**: Global CSS styling
**Contains**:
- Tailwind directives
- Reset styles
- Font configuration
- Base HTML/body styles

### package.json
**Purpose**: Node.js project configuration
**Contains**:
- Project metadata
- Scripts (dev, build, start)
- Dependencies (Next.js, React, Tailwind, etc.)

### Configuration Files
- **tsconfig.json** - TypeScript settings
- **tailwind.config.js** - Tailwind CSS customization
- **next.config.js** - Next.js settings
- **postcss.config.js** - PostCSS plugins

## 🗄️ Database Schema

### supabase/schema.sql

#### contacts Table
```sql
- id (UUID, auto-generated)
- name (TEXT, optional)
- phone_number (TEXT, required, unique)
- tags (TEXT[], optional)
- created_at (TIMESTAMP, auto)
- updated_at (TIMESTAMP, auto)
```
**Purpose**: Store customer contact information
**Indexes**: phone_number, created_at

#### sms_campaigns Table
```sql
- id (UUID, auto-generated)
- prompt (TEXT, required)
- link (TEXT, optional)
- content (TEXT, max 1500 chars)
- status (TEXT, values: draft/scheduled/sent/failed)
- scheduled_at (TIMESTAMP, optional)
- created_at (TIMESTAMP, auto)
- updated_at (TIMESTAMP, auto)
```
**Purpose**: Store SMS campaign information and generated content
**Indexes**: status, scheduled_at, created_at

#### message_logs Table
```sql
- id (UUID, auto-generated)
- campaign_id (UUID, foreign key)
- contact_id (UUID, foreign key)
- status (TEXT, values: pending/sent/failed)
- sent_at (TIMESTAMP, optional)
- error_message (TEXT, optional)
- created_at (TIMESTAMP, auto)
```
**Purpose**: Track SMS delivery status per contact
**Indexes**: campaign_id, contact_id, status

**Relationships**:
- One campaign can have many message logs
- One contact can have many message logs
- Cascading delete from campaigns

## 🔄 Data Flow Examples

### Flow 1: Generate SMS Content
```
User Input (Frontend)
    ↓
POST /generate-sms (Backend)
    ↓
Call DeepSeek API
    ↓
Return generated SMS (Frontend)
    ↓
Display in preview area
```

### Flow 2: Schedule Campaign
```
User submits form (Frontend)
    ↓
POST /schedule-sms (Backend)
    ↓
Insert into sms_campaigns table
    ↓
Create message_logs for selected contacts
    ↓
Return campaign_id (Frontend)
    ↓
Show success message
```

### Flow 3: Process Queue (Automated)
```
GitHub Actions / Cron Job
    ↓
GET /process-queue (Backend)
    ↓
Query scheduled messages (Supabase)
    ↓
Filter by scheduled_at <= now
    ↓
For each campaign:
  - Get associated contacts
  - Send SMS via Twilio
  - Update message_logs
  - Update campaign status
    ↓
Return processed count
```

## 🔐 Security Considerations

### Backend
- CORS enabled (customize in production)
- No authentication (add JWT tokens if needed)
- Environment variables for secrets
- Input validation via Pydantic

### Frontend
- HTTPS in production
- Anon key from Supabase (limited permissions)
- No sensitive data in localStorage
- CSRF protection via Next.js

### Database
- Row Level Security (RLS) policies in place
- Foreign key constraints
- Cascade delete rules

## 🚀 Scalability Notes

### Current Setup (Development)
- Single backend instance
- Direct database access (no connection pooling)
- Synchronous SMS sending
- No message queue

### Production Improvements
- Load balancer for backend
- Connection pooling for database
- Message queue (Redis, RabbitMQ)
- Async task processor (Celery)
- Caching layer (Redis)
- CDN for frontend static assets
- Database replication and backups

## 📊 File Dependencies

```
main.py
├── requirements.txt (imports)
├── .env (configuration)
├── supabase SDK
├── openai SDK
└── twilio SDK

Frontend App
├── package.json (imports)
├── .env.local (configuration)
├── lib/api.ts (backend communication)
├── lib/supabase.ts (database access)
├── components/* (UI components)
└── styles/* (styling)

Configuration Flow
├── .gitignore (version control)
├── .github/workflows/sms-cron.yml (automation)
└── supabase/schema.sql (database setup)
```

## 🔌 External API Integrations

### DeepSeek
- **Endpoint**: https://api.deepseek.com/chat/completions
- **Method**: POST
- **Used by**: Backend `/generate-sms`
- **Purpose**: AI-powered SMS generation

### Supabase
- **Type**: PostgreSQL Database-as-a-Service
- **Used by**: Both frontend and backend
- **Operations**: CRUD on contacts, campaigns, logs
- **Authentication**: Anon key for client-side access

### Twilio
- **Endpoint**: https://api.twilio.com/2010-04-01/Accounts
- **Method**: POST to Messages resource
- **Used by**: Backend `/process-queue`
- **Purpose**: Actually send SMS messages (currently placeholder)

## 🧪 Testing Approach

### Backend Testing
1. Start backend: `python main.py`
2. Visit Swagger UI: http://localhost:8000/docs
3. Try endpoints with test data
4. Check Supabase dashboard for data

### Frontend Testing
1. Start frontend: `npm run dev`
2. Visit http://localhost:3000
3. Test form inputs and API calls
4. Check browser console for errors

### Integration Testing
1. Add contact via frontend
2. Generate SMS with DeepSeek
3. Schedule campaign
4. Call `/process-queue` manually
5. Check message_logs in Supabase

## 📈 Monitoring & Debugging

### Backend Logs
- Console output from `python main.py`
- FastAPI error responses
- Environment variable validation

### Frontend Logs
- Browser console (F12)
- Network tab for API calls
- React error boundaries

### Database Monitoring
- Supabase Dashboard
- SQL Editor for queries
- Realtime data viewer

---

This architecture provides a solid foundation for SMS campaign management with room for scaling and extending functionality.
