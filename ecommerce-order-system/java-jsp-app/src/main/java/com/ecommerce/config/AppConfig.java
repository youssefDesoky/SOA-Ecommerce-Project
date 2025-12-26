package com.ecommerce.config;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

/**
 * Central configuration class for the Java JSP application.
 * Loads settings from .env file or falls back to defaults.
 */
public class AppConfig {
    
    private static final Properties properties = new Properties();
    private static boolean loaded = false;
    
    // Default values
    private static final String DEFAULT_CUSTOMER_SERVICE_URL = "http://127.0.0.1:5004/api/customers";
    private static final String DEFAULT_INVENTORY_SERVICE_URL = "http://127.0.0.1:5002/api/inventory";
    private static final String DEFAULT_ORDER_SERVICE_URL = "http://127.0.0.1:5001/api/orders";
    private static final String DEFAULT_PRICING_SERVICE_URL = "http://127.0.0.1:5003/api/pricing";
    private static final String DEFAULT_NOTIFICATION_SERVICE_URL = "http://127.0.0.1:5005/api/notifications";
    
    static {
        loadConfig();
    }
    
    private static void loadConfig() {
        if (loaded) return;
        
        // Try to load from .env file in multiple locations
        String[] possiblePaths = {
            ".env",
            "../.env",
            "java-jsp-app/.env",
            System.getProperty("user.dir") + "/.env"
        };
        
        for (String pathStr : possiblePaths) {
            try {
                Path path = Paths.get(pathStr);
                if (Files.exists(path)) {
                    try (InputStream input = Files.newInputStream(path)) {
                        properties.load(input);
                        loaded = true;
                        System.out.println("Loaded config from: " + path.toAbsolutePath());
                        break;
                    }
                }
            } catch (IOException e) {
                // Continue to next path
            }
        }
        
        // Also try loading from classpath
        if (!loaded) {
            try (InputStream input = AppConfig.class.getClassLoader().getResourceAsStream(".env")) {
                if (input != null) {
                    properties.load(input);
                    loaded = true;
                    System.out.println("Loaded config from classpath");
                }
            } catch (IOException e) {
                // Use defaults
            }
        }
        
        if (!loaded) {
            System.out.println("No .env file found, using default configuration");
        }
    }
    
    public static String get(String key, String defaultValue) {
        // First check system environment variables
        String envValue = System.getenv(key);
        if (envValue != null && !envValue.isEmpty()) {
            return envValue;
        }
        // Then check .env file
        return properties.getProperty(key, defaultValue);
    }
    
    // ==================== SERVICE URLS ====================
    
    public static String getCustomerServiceUrl() {
        return get("CUSTOMER_SERVICE_URL", DEFAULT_CUSTOMER_SERVICE_URL);
    }
    
    public static String getInventoryServiceUrl() {
        return get("INVENTORY_SERVICE_URL", DEFAULT_INVENTORY_SERVICE_URL);
    }
    
    public static String getOrderServiceUrl() {
        return get("ORDER_SERVICE_URL", DEFAULT_ORDER_SERVICE_URL);
    }
    
    public static String getPricingServiceUrl() {
        return get("PRICING_SERVICE_URL", DEFAULT_PRICING_SERVICE_URL);
    }
    
    public static String getNotificationServiceUrl() {
        return get("NOTIFICATION_SERVICE_URL", DEFAULT_NOTIFICATION_SERVICE_URL);
    }
}
