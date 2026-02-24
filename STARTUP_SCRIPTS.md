# 🚀 SMS Campaign Manager - Quick Start Scripts

Three easy startup scripts to run the application, automatically handling port conflicts.

## 📋 What They Do

All scripts:
- ✅ Detect if ports 8500 (backend) or 3500 (frontend) are in use
- ✅ Kill any existing processes on those ports
- ✅ Configure environment variables automatically
- ✅ Start both backend and frontend

## 📌 Choose Your Platform

### 🍎 macOS Users

**Recommended**: Uses separate Terminal windows

```bash
./start-macos.sh
```

This opens two new Terminal windows:
- Window 1: Backend server (port 8500)
- Window 2: Frontend server (port 3500)

**Alternatively**, use the universal script:
```bash
./start.sh
```

### 🪟 Windows Users

**Use**: Batch file for Windows Command Prompt

```bash
start.bat
```

Or double-click `start.bat` in File Explorer.

Opens two new Command Prompt windows with both services.

### 🐧 Linux / Universal (All Platforms)

**Use**: Universal bash script

```bash
./start.sh
```

- Backend runs in the background
- Frontend runs in the foreground
- Press `Ctrl+C` to stop both services

---

## ⚙️ Initial Setup (Before First Run)

### 1. Configure Backend

```bash
cd backend
cp .env.example .env
# Edit .env with your credentials:
# - SUPABASE_URL
# - SUPABASE_KEY
# - DEEPSEEK_API_KEY
nano .env
```

### 2. Configure Frontend

```bash
cd frontend
cp .env.example .env.local
# Edit .env.local with your credentials:
# - NEXT_PUBLIC_SUPABASE_URL
# - NEXT_PUBLIC_SUPABASE_ANON_KEY
nano .env.local
```

### 3. Install Frontend Dependencies

```bash
cd frontend
npm install
```

---

## 🏃 Running the Application

### macOS
```bash
./start-macos.sh
```

### Windows
```bash
start.bat
```
Or double-click the file.

### Linux/Universal
```bash
./start.sh
```

---

## 📍 Access Points

After starting, you can access:

| Service | URL | Purpose |
|---------|-----|---------|
| Frontend | http://localhost:3500 | Web dashboard |
| Backend | http://localhost:8500 | API server |
| API Docs | http://localhost:8500/docs | Interactive Swagger UI |

---

## 🔧 Port Configuration

The scripts automatically use:
- **Backend**: Port 8500 (was 8000)
- **Frontend**: Port 3500

To change ports, edit the script files:

**start.sh** / **start-macos.sh** / **start.bat**:
```bash
BACKEND_PORT=8500   # Change to desired port
FRONTEND_PORT=3500  # Change to desired port
```

---

## 🛑 Stopping the Services

### macOS / Windows
- Close the Terminal/Command Prompt windows, or
- Press `Ctrl+C` in each window

### Linux (start.sh)
- Press `Ctrl+C` in the terminal
- Scripts automatically cleanup processes on exit

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Port 8500 already in use" | Script will automatically kill it |
| ".env file not found" | Run setup: `cp .env.example .env` |
| "npm not found" | Install Node.js: https://nodejs.org |
| "python not found" | Install Python: https://python.org |
| "Permission denied" | Make script executable: `chmod +x start*.sh` |
| Port still in use after kill | Restart your computer |

---

## 📊 What Each Script Does

### start.sh (Universal - All Platforms)
```bash
1. Stop any existing processes on ports 8500 & 3500
2. Read/update backend .env for port 8500
3. Read/update frontend .env.local for API URL
4. Start backend in background (Python FastAPI)
5. Install frontend dependencies if needed
6. Start frontend in foreground (Next.js)
7. Cleanup on exit (Ctrl+C)
```

### start-macos.sh (macOS)
```bash
1. Stop any existing processes using lsof
2. Update configuration files
3. Use AppleScript to open two Terminal windows
4. Backend in window 1
5. Frontend in window 2
```

### start.bat (Windows)
```bash
1. Find processes using netstat
2. Kill processes with taskkill command
3. Open backend in new Command Prompt window
4. Open frontend in new Command Prompt window
5. Both run independently
```

---

## 🔄 Multiple Instances

If you want to run multiple instances on different ports:

1. Edit the script to use different ports:
   ```bash
   BACKEND_PORT=8501
   FRONTEND_PORT=3501
   ```

2. Save with a new name (e.g., `start-instance2.sh`)

3. Run both versions

---

## 📝 Script Details

### Port Detection / Killing

**macOS/Linux** - Uses `lsof` (most reliable):
```bash
lsof -ti :8500    # Get process ID on port 8500
kill -9 <PID>     # Force kill
```

**Windows** - Uses `netstat` and `taskkill`:
```bash
netstat -ano | findstr :8500      # Find process
taskkill /PID <PID> /F             # Force kill
```

### Environment Variables Auto-Update

Scripts automatically:
- Set `BACKEND_PORT=8500` in backend/.env
- Set `NEXT_PUBLIC_API_URL=http://localhost:8500` in frontend/.env.local

This ensures frontend knows where to reach the backend API.

---

## ✅ Verification

After starting, verify everything works:

1. **Check Frontend**
   ```bash
   curl http://localhost:3500
   ```

2. **Check Backend API**
   ```bash
   curl http://localhost:8500/health
   ```

3. **Check API Documentation**
   - Open http://localhost:8500/docs in browser
   - Should see Swagger UI with all endpoints

---

## 🎯 Next Steps

After the apps are running:

1. Open http://localhost:3500 in your browser
2. Go to "Contacts" and add a test contact
3. Go to "New Campaign"
4. Enter a prompt like "Write a greeting message"
5. Click "Generate with DeepSeek"
6. watch the AI generate content

---

## 🆘 Still Having Issues?

1. Check that Python and Node.js are installed:
   ```bash
   python --version    # Should be 3.8+
   node --version     # Should be 16+
   ```

2. Verify .env files have credentials:
   ```bash
   cat backend/.env | grep SUPABASE
   cat frontend/.env.local | grep SUPABASE
   ```

3. Check the documentation:
   - [SETUP_GUIDE.md](SETUP_GUIDE.md) - Detailed setup
   - [README.md](README.md) - Project overview
   - [backend/README.md](backend/README.md) - Backend help
   - [frontend/README.md](frontend/README.md) - Frontend help

---

**Happy coding! 🚀**
