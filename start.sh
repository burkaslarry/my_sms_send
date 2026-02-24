#!/bin/bash

# SMS Campaign Manager - Start Script
# Starts backend on port 8500 and frontend on port 3500
# Automatically kills any existing processes using these ports

set -e

BACKEND_PORT=8500
FRONTEND_PORT=3500
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== SMS Campaign Manager Startup Script ===${NC}\n"

# Function to kill process on a specific port
kill_process_on_port() {
    local port=$1
    local port_name=$2
    
    # Get the process ID using lsof (if available) or netstat
    if command -v lsof &> /dev/null; then
        local pid=$(lsof -ti :$port 2>/dev/null || true)
    else
        # Fallback to netstat/ss for finding processes
        local pid=$(netstat -tlnp 2>/dev/null | grep ":$port " | awk '{print $7}' | cut -d'/' -f1 || true)
        if [ -z "$pid" ]; then
            pid=$(ss -tlnp 2>/dev/null | grep ":$port " | awk '{print $7}' | cut -d'/' -f1 || true)
        fi
    fi
    
    if [ ! -z "$pid" ]; then
        echo -e "${YELLOW}Found process on port $port (PID: $pid)${NC}"
        echo -e "${YELLOW}Killing $port_name process...${NC}"
        kill -9 $pid 2>/dev/null || true
        sleep 1
        echo -e "${GREEN}✓ Killed process on port $port${NC}\n"
    else
        echo -e "${GREEN}✓ Port $port is free${NC}\n"
    fi
}

# Check and kill processes on ports
echo -e "${YELLOW}Checking for existing processes on ports ${BACKEND_PORT} and ${FRONTEND_PORT}...${NC}\n"
kill_process_on_port $BACKEND_PORT "Backend"
kill_process_on_port $FRONTEND_PORT "Frontend"

# Verify ports are free
verify_port() {
    local port=$1
    local port_name=$2
    
    if command -v lsof &> /dev/null; then
        if lsof -i :$port &> /dev/null; then
            echo -e "${RED}✗ Port $port is still in use!${NC}"
            return 1
        fi
    fi
    return 0
}

# Create backend .env from .env.example if it doesn't exist
echo -e "${YELLOW}Setting up backend configuration...${NC}"
if [ ! -f "$SCRIPT_DIR/backend/.env" ]; then
    if [ -f "$SCRIPT_DIR/backend/.env.example" ]; then
        cp "$SCRIPT_DIR/backend/.env.example" "$SCRIPT_DIR/backend/.env"
        echo -e "${GREEN}✓ Created backend/.env from .env.example${NC}"
        echo -e "${YELLOW}⚠ Please edit backend/.env with your API keys:${NC}"
        echo -e "  - SUPABASE_URL"
        echo -e "  - SUPABASE_KEY"
        echo -e "  - DEEPSEEK_API_KEY\n"
    else
        echo -e "${RED}✗ backend/.env.example not found${NC}"
        exit 1
    fi
fi

# Update backend .env to use port 8500
if grep -q "BACKEND_PORT" "$SCRIPT_DIR/backend/.env"; then
    sed -i.bak "s/BACKEND_PORT=.*/BACKEND_PORT=$BACKEND_PORT/" "$SCRIPT_DIR/backend/.env"
else
    echo "BACKEND_PORT=$BACKEND_PORT" >> "$SCRIPT_DIR/backend/.env"
fi
echo -e "${GREEN}✓ Backend configured for port ${BACKEND_PORT}${NC}\n"

# Update frontend .env.local for backend URL
echo -e "${YELLOW}Configuring frontend for backend on port ${BACKEND_PORT}...${NC}"
if [ -f "$SCRIPT_DIR/frontend/.env.local" ]; then
    # Update or add NEXT_PUBLIC_API_URL
    if grep -q "NEXT_PUBLIC_API_URL" "$SCRIPT_DIR/frontend/.env.local"; then
        sed -i.bak "s|NEXT_PUBLIC_API_URL=.*|NEXT_PUBLIC_API_URL=http://localhost:$BACKEND_PORT|" "$SCRIPT_DIR/frontend/.env.local"
    else
        echo "NEXT_PUBLIC_API_URL=http://localhost:$BACKEND_PORT" >> "$SCRIPT_DIR/frontend/.env.local"
    fi
    echo -e "${GREEN}✓ Frontend configured for backend on port ${BACKEND_PORT}${NC}\n"
else
    echo -e "${YELLOW}⚠ frontend/.env.local not found. Make sure to set NEXT_PUBLIC_API_URL=http://localhost:${BACKEND_PORT}${NC}\n"
fi

# Create a function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Shutting down services...${NC}"
    kill_process_on_port $BACKEND_PORT "Backend"
    kill_process_on_port $FRONTEND_PORT "Frontend"
    exit 0
}

trap cleanup EXIT INT TERM

# Start backend
echo -e "${GREEN}=== Starting Backend ===${NC}"
echo -e "Port: ${BACKEND_PORT}"
echo -e "Command: python main.py\n"

cd "$SCRIPT_DIR/backend"

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: backend/.env not found!${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env and fill in your credentials:${NC}"
    echo -e "  cd backend"
    echo -e "  cp .env.example .env"
    echo -e "  # Edit .env with your Supabase and DeepSeek API keys"
    exit 1
fi

# Start backend in background
python main.py &
BACKEND_PID=$!
echo -e "${GREEN}✓ Backend started (PID: $BACKEND_PID)${NC}"
sleep 2

# Start frontend
echo -e "\n${GREEN}=== Starting Frontend ===${NC}"
echo -e "Port: ${FRONTEND_PORT}"
echo -e "Command: npm install && npm run dev\n"

cd "$SCRIPT_DIR/frontend"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing dependencies...${NC}"
    npm install
    echo -e "${GREEN}✓ Dependencies installed${NC}\n"
fi

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo -e "${RED}Error: frontend/.env.local not found!${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env.local and fill in your credentials:${NC}"
    echo -e "  cd frontend"
    echo -e "  cp .env.example .env.local"
    echo -e "  # Edit .env.local with your Supabase credentials"
    exit 1
fi

# Start frontend (this will run in foreground)
echo -e "${GREEN}Starting Next.js development server...${NC}"
npm run dev

