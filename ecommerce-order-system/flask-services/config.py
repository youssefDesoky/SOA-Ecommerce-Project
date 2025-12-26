"""
Central configuration file for all Flask microservices.
Loads settings from environment variables with fallback defaults.

Usage:
    from config import Config
    
    # Access settings
    db_host = Config.DB_HOST
    smtp_server = Config.SMTP_SERVER
"""

import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    """Configuration settings for all services"""
    
    # ==================== DATABASE ====================
    DB_HOST = os.getenv('DB_HOST', 'localhost')
    DB_USER = os.getenv('DB_USER', 'root')
    DB_PASSWORD = os.getenv('DB_PASSWORD', '')
    DB_NAME = os.getenv('DB_NAME', 'ecommerce_system')
    
    # ==================== SERVICE URLS ====================
    CUSTOMER_SERVICE_URL = os.getenv('CUSTOMER_SERVICE_URL', 'http://localhost:5004/api/customers')
    INVENTORY_SERVICE_URL = os.getenv('INVENTORY_SERVICE_URL', 'http://localhost:5002/api/inventory')
    ORDER_SERVICE_URL = os.getenv('ORDER_SERVICE_URL', 'http://localhost:5001/api/orders')
    PRICING_SERVICE_URL = os.getenv('PRICING_SERVICE_URL', 'http://localhost:5003/api/pricing')
    NOTIFICATION_SERVICE_URL = os.getenv('NOTIFICATION_SERVICE_URL', 'http://localhost:5005/api/notifications')
    
    # ==================== SERVICE PORTS ====================
    CUSTOMER_SERVICE_PORT = int(os.getenv('CUSTOMER_SERVICE_PORT', 5004))
    INVENTORY_SERVICE_PORT = int(os.getenv('INVENTORY_SERVICE_PORT', 5002))
    ORDER_SERVICE_PORT = int(os.getenv('ORDER_SERVICE_PORT', 5001))
    PRICING_SERVICE_PORT = int(os.getenv('PRICING_SERVICE_PORT', 5003))
    NOTIFICATION_SERVICE_PORT = int(os.getenv('NOTIFICATION_SERVICE_PORT', 5005))
    
    # ==================== EMAIL (SMTP) ====================
    SMTP_SERVER = os.getenv('SMTP_SERVER', 'smtp.gmail.com')
    SMTP_PORT = int(os.getenv('SMTP_PORT', 587))
    SENDER_EMAIL = os.getenv('SENDER_EMAIL', '')
    SENDER_PASSWORD = os.getenv('SENDER_PASSWORD', '')
    
    # ==================== APP SETTINGS ====================
    DEBUG = os.getenv('DEBUG', 'True').lower() in ('true', '1', 'yes')
    HOST = os.getenv('HOST', '0.0.0.0')
    
    @classmethod
    def get_db_config(cls):
        """Return database configuration as dictionary"""
        return {
            'host': cls.DB_HOST,
            'user': cls.DB_USER,
            'password': cls.DB_PASSWORD,
            'database': cls.DB_NAME
        }
