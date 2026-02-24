#!/usr/bin/env python3
"""
Cron Worker Script
This script is meant to be called periodically (e.g., every 10 minutes) via GitHub Actions or a cron job.
It calls the /process-queue endpoint of the backend to process scheduled SMS campaigns.
"""

import requests
import os
from dotenv import load_dotenv
import logging
from datetime import datetime

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

def run_worker():
    """Call the backend's /process-queue endpoint"""
    backend_url = os.getenv("BACKEND_URL", "http://localhost:8000")
    endpoint = f"{backend_url}/process-queue"
    
    try:
        logger.info(f"[{datetime.now()}] Starting SMS queue processing...")
        logger.info(f"Calling endpoint: {endpoint}")
        
        response = requests.get(endpoint, timeout=30)
        response.raise_for_status()
        
        result = response.json()
        logger.info(f"Queue processing completed: {result}")
        
        return True
    
    except requests.exceptions.ConnectionError:
        logger.error(f"Failed to connect to backend at {backend_url}")
        logger.error("Make sure your backend is running (e.g., on Render or your server)")
        return False
    
    except requests.exceptions.Timeout:
        logger.error("Request to backend timed out")
        return False
    
    except Exception as e:
        logger.error(f"Error calling backend: {str(e)}")
        return False

if __name__ == "__main__":
    success = run_worker()
    exit(0 if success else 1)
