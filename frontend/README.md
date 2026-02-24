# SMS Campaign Frontend (Next.js + Tailwind)

## Setup Instructions

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment Variables
Copy `.env.example` to `.env.local`:
```bash
cp .env.example .env.local
```

Then fill in your values:
- `NEXT_PUBLIC_API_URL` - Your backend URL (default: http://localhost:8000)
- `NEXT_PUBLIC_SUPABASE_URL` - Your Supabase URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Your Supabase anon key

### 3. Run Development Server
```bash
npm run dev
```

The frontend will be available at `http://localhost:3000`

## Features

- **Dashboard Navigation**: Easy-to-use sidebar for navigation
- **Contact Management**: Add, view, and delete contacts
- **SMS Generation**: Use DeepSeek AI to generate marketing messages
- **Campaign Scheduling**: Schedule SMS campaigns for later sending
- **Contact Selection**: Choose specific recipients or send to all
- **Real-time Updates**: Uses Supabase for real-time data sync

## Pages

- `/` - Home (redirects to Contacts)
- `/contacts` - View and manage contacts
- `/campaign` - Create and schedule SMS campaigns

## Technologies

- **Framework**: Next.js 14
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **API**: Axios + OpenAPI compatible client
- **Database**: Supabase
- **Notifications**: React Hot Toast

## Deployment to Vercel

1. Push your code to GitHub
2. Go to https://vercel.com and import your repository
3. Set the environment variables:
   - `NEXT_PUBLIC_API_URL`
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
4. Deploy!

## Notes

- All communication with the backend goes through the Python FastAPI server
- Contacts can be managed directly from the Supabase client (supabase-js)
- The app is fully responsive and works on mobile devices
