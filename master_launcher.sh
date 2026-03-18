#!/bin/bash

# ==========================================
# DELIVERY - Master Launcher (Cloudflare Edition)
# ==========================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Starting DELIVERY Full Suite...${NC}"

# 0. Cleanup ports 8000 and 5173
echo -e "${GREEN}[0/6] Cleaning up ports and processes...${NC}"
pkill -f "gunicorn"
pkill -f "vite"
pkill -f "cloudflared"
sleep 2

# 1. Anti-Sleep Mode
echo -e "${GREEN}[1/6] Activating Anti-Sleep Mode (caffeinate)...${NC}"
caffeinate -d -i -m -s &
CAFFEINATE_PID=$!

cleanup() {
    echo -e "${RED}\nStopping all services...${NC}"
    kill $CAFFEINATE_PID
    pkill -P $$ 
    pkill -f "cloudflared"
    pkill -f "gunicorn"
    pkill -f "vite"
    pkill -f "celery"
    echo -e "${GREEN}Goodbye!${NC}"
    exit
}
trap cleanup SIGINT

# 2. Database (PostgreSQL)
echo -e "${GREEN}[2/7] Checking Database...${NC}"
if ! pgrep -x "postgres" > /dev/null; then
    echo "PostgreSQL not running. Attempting to start via brew..."
    brew services start postgresql@14 || brew services start postgresql
    sleep 3
fi

# 2.1 Redis
echo -e "${GREEN}[2.1/7] Checking Redis...${NC}"
if ! pgrep -x "redis-server" > /dev/null; then
    echo "Redis not running. Attempting to start via brew..."
    if brew services list | grep -q "redis.*started"; then
        brew services restart redis
    else
        brew services start redis
    fi
    sleep 3
fi

# 2.2 Frontend Dependencies
echo -e "${GREEN}[2.2/7] Checking Frontend Dependencies...${NC}"
if [ -d "frontend" ] && [ ! -d "frontend/node_modules" ]; then
    echo "Frontend node_modules not found. Installing..."
    cd frontend && npm install && cd ..
fi

# 2b. Initialize DB
echo -e "${GREEN}[2b/7] Initializing Database (migrate + components)...${NC}"
cd backend
source venv/bin/activate
python3 manage.py migrate --no-input > /dev/null 2>&1
# python3 manage.py sync_geo > /dev/null 2>&1  # Uncomment if needed
# python3 manage.py crear_documentos_legales > /dev/null 2>&1  # Uncomment if needed
deactivate
cd ..

# 3. Backend Tunnel
echo -e "${GREEN}[3/6] Starting Backend Tunnel...${NC}"
TUNNEL_BACK_LOG="/tmp/cf_back.log"
> "$TUNNEL_BACK_LOG"
cloudflared tunnel --url http://127.0.0.1:8000 > "$TUNNEL_BACK_LOG" 2>&1 &

echo "Waiting for Backend Tunnel URL..."
BE_URL=""
for i in {1..30}; do
    BE_URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$TUNNEL_BACK_LOG" | grep -v "api.trycloudflare.com" | head -n 1)
    if [ ! -z "$BE_URL" ]; then break; fi
    sleep 1
    echo -n "."
done

if [ -z "$BE_URL" ]; then
    echo -e "\n${RED}Error: Could not obtain Backend Cloudflare URL. Check /tmp/cf_back.log${NC}"
else
    echo -e "\n${GREEN}Backend URL: $BE_URL${NC}"
fi

# Update configs (PRE-START)
if [ ! -z "$BE_URL" ]; then
    echo -e "${BLUE}Updating Backend, Mobile and Frontend configs with ${BE_URL}...${NC}"
    
    # Backend .env
    if [ -f "backend/.env" ]; then
        sed -i '' "s|CLOUDFLARE_URL=.*|CLOUDFLARE_URL=$BE_URL|g" "backend/.env"
    else
        echo "CLOUDFLARE_URL=$BE_URL" > "backend/.env"
    fi

    # Frontend .env
    if [ -f "frontend/.env" ]; then
        sed -i '' "s|VITE_API_URL=.*|VITE_API_URL=$BE_URL/api|g" "frontend/.env"
        WS_URL=$(echo "$BE_URL" | sed 's|https://|wss://|')
        sed -i '' "s|VITE_WS_URL=.*|VITE_WS_URL=$WS_URL/ws|g" "frontend/.env"
    fi
    
    # Mobile ApiConfig
    # Inyecta la URL de Cloudflare en el defaultValue para que funcione sin configurar nada más.
    echo -e "${BLUE}Injecting $BE_URL into mobile/lib/config/network/api_config.dart...${NC}"
    python3 -c "
import re, os
path = 'mobile/lib/config/network/api_config.dart'
if os.path.exists(path):
    content = open(path).read()
    pattern = r\"String\.fromEnvironment\('DEV_API_URL'(, defaultValue: '[^']*')?\)\"
    replacement = f\"String.fromEnvironment('DEV_API_URL', defaultValue: '{os.environ.get('BE_URL')}')\"
    new_content = re.sub(pattern, replacement, content)
    if content != new_content:
        open(path, 'w').write(new_content)
        print('Successfully updated ApiConfig.dart')
    else:
        print('Warning: DEV_API_URL pattern not found in ApiConfig.dart')
else:
    print(f'Error: {path} not found')
"
    
    echo -e "${BLUE}Syncing Flutter dependencies...${NC}"
    cd mobile && flutter pub get > /dev/null 2>&1 && cd ..
fi

# 4. Backend (Gunicorn)
echo -e "${GREEN}[4/6] Starting Backend...${NC}"
cd backend
chmod +x deploy/scripts/run_prod.sh
./deploy/scripts/run_prod.sh > /tmp/delivery_backend.log 2>&1 &
BACKEND_PID=$!

# 4.1 Celery Services
echo -e "${GREEN}[4.1/6] Starting Celery Worker & Beat...${NC}"
source venv/bin/activate
celery -A config.celery worker --loglevel=info > /tmp/celery_worker.log 2>&1 &
CELERY_WORKER_PID=$!
celery -A config.celery beat --loglevel=info > /tmp/celery_beat.log 2>&1 &
CELERY_BEAT_PID=$!
deactivate
cd ..

# 5. Frontend (Vite)
echo -e "${GREEN}[5/6] Starting Frontend...${NC}"
if [ -d "frontend" ]; then
    cd frontend
    npm run dev > /tmp/delivery_frontend.log 2>&1 &
    FRONTEND_PID=$!
    cd ..
else
    echo -e "${RED}Frontend directory not found. Skipping.${NC}"
fi

# 6. Frontend Tunnel
echo -e "${GREEN}[6/6] Starting Frontend Tunnel...${NC}"
TUNNEL_FRONT_LOG="/tmp/cf_front.log"
> "$TUNNEL_FRONT_LOG"
cloudflared tunnel --url http://localhost:5173 > "$TUNNEL_FRONT_LOG" 2>&1 &

echo "Waiting for Frontend Tunnel URL..."
FE_URL=""
for i in {1..30}; do
    FE_URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$TUNNEL_FRONT_LOG" | grep -v "api.trycloudflare.com" | head -n 1)
    if [ ! -z "$FE_URL" ]; then break; fi
    sleep 1
    echo -n "."
done

if [ -z "$FE_URL" ]; then
    echo -e "\n${RED}Error: Could not obtain Frontend Cloudflare URL. Check /tmp/cf_back.log${NC}"
else
    echo -e "\n${GREEN}Frontend URL: $FE_URL${NC}"
fi

echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}DELIVERY IS LIVE!${NC}"
echo -e "Backend API: ${BLUE}$BE_URL${NC}"
echo -e "Web Frontend: ${BLUE}$FE_URL${NC}"
echo -e "Mobile Config updated automatically.${NC}"
echo -e "--------------------------------------------"
echo -e "${BLUE}Streaming Logs (Backend & Frontend):${NC}"
echo -e "Press ${RED}Ctrl+C${NC} to stop everything."
echo -e "${BLUE}============================================${NC}"

tail -f "$TUNNEL_BACK_LOG" "$TUNNEL_FRONT_LOG" /tmp/delivery_backend.log /tmp/delivery_frontend.log
