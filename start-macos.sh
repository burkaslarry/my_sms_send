#!/bin/bash

# SMS Campaign Manager - macOS Terminal Launcher
# Opens backend and frontend in separate Terminal windows
# Automatically kills any existing processes using ports 8500 and 3500

BACKEND_PORT=8500
FRONTEND_PORT=3500
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== SMS Campaign Manager - macOS Launcher ===${NC}\n"

# Function to kill process on port
kill_if_exists() {
    local port=$1
    local name=$2
    
    # Try lsof first (most reliable on macOS)
    if command -v lsof &> /dev/null; then
        local pid=$(lsof -ti :$port 2>/dev/null || true)
        if [ ! -z "$pid" ]; then
            echo -e "${YELLOW}Killing $name on port $port (PID: $pid)${NC}"
            kill -9 $pid 2>/dev/null || true
            sleep 1
        fi
    fi
}

# Kill existing processes
echo -e "${YELLOW}Checking for existing processes...${NC}"
kill_if_exists $BACKEND_PORT "Backend"
kill_if_exists $FRONTEND_PORT "Frontend"
echo -e "${GREEN}✓ Ports cleared${NC}\n"

# Check if .env files exist
if [ ! -f "$PROJECT_DIR/backend/.env" ]; then
    echo -e "${RED}✗ backend/.env not found${NC}"
    echo -e "${YELLOW}Please run: cd backend && cp .env.example .env${NC}"
    exit 1
fi

if [ ! -f "$PROJECT_DIR/frontend/.env.local" ]; then
    echo -e "${RED}✗ frontend/.env.local not found${NC}"
    echo -e "${YELLOW}Please run: cd frontend && cp .env.example .env.local${NC}"
    exit 1
fi

# Update backend port in .env
if grep -q "BACKEND_PORT" "$PROJECT_DIR/backend/.env"; then
    sed -i.bak "s/BACKEND_PORT=.*/BACKEND_PORT=$BACKEND_PORT/" "$PROJECT_DIR/backend/.env"
else
    echo "BACKEND_PORT=$BACKEND_PORT" >> "$PROJECT_DIR/backend/.env"
fi

# Update frontend API URL
if grep -q "NEXT_PUBLIC_API_URL" "$PROJECT_DIR/frontend/.env.local"; then
    sed -i.bak "s|NEXT_PUBLIC_API_URL=.*|NEXT_PUBLIC_API_URL=http://localhost:$BACKEND_PORT|" "$PROJECT_DIR/frontend/.env.local"
else
    echo "NEXT_PUBLIC_API_URL=http://localhost:$BACKEND_PORT" >> "$PROJECT_DIR/frontend/.env.local"
fi

echo -e "${GREEN}✓ Configuration updated${NC}\n"

# Open iTerm2 or Terminal with two windows
if command -v open &> /dev/null; then
    
    # Create AppleScript to open two Terminal windows
    cat > /tmp/sms-launcher.applescript << 'EOF'
tell application "Terminal"
    activate
    
    -- Window 1: Backend
    do script "cd \"$PROJECT_DIR\" && cd backend && python main.py"
    
    -- Window 2: Frontend
    tell application "System Events" to keystroke "t" using command down
    delay 0.5
    do script "cd \"$PROJECT_DIR\" && cd frontend && npm run dev" in front window
end tell
EOF
    
    # Run the AppleScript
    /usr/bin/osascript /tmp/sms-launcher.applescript 2>/dev/null || {
        echo -e "${YELLOW}macOS Terminal script failed, using standard shell instead${NC}"
        echo -e "${YELLOW}Opening in two separate Terminal windows...${NC}"
        
        # Fallback: use open command to run in background
        osascript -e 'tell app "Terminal" to do script "cd \"'"$PROJECT_DIR"'\" && cd backend && python main.py"' 2>/dev/null &
        sleep 1
        osascript -e 'tell app "Terminal" to do script "cd \"'"$PROJECT_DIR"'\" && cd frontend && npm run dev"' 2>/dev/null &
    }
else
    echo -e "${RED}Terminal application not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Backend started on http://localhost:${BACKEND_PORT}${NC}"
echo -e "${GREEN}✓ Frontend will start on http://localhost:3500${NC}"
echo -e "${GREEN}✓ Check two Terminal windows${NC}\n"

echo -e "${YELLOW}URLs:${NC}"
echo -e "  Frontend:  http://localhost:3500"
echo -e "  Backend:   http://localhost:${BACKEND_PORT}"
echo -e "  API Docs:  http://localhost:${BACKEND_PORT}/docs\n"
