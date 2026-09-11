import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

public class App {
    private static final Logger logger = LoggerFactory.getLogger(App.class);
    private static final Logger appLogger = LoggerFactory.getLogger("app");
    private static final Logger dbLogger = LoggerFactory.getLogger("database");
    private static final Logger apiLogger = LoggerFactory.getLogger("api");
    
    public static void main(String[] args) {
        int counter = 0;
        
        logger.info("Starting Java basic logging example with SLF4J + Logback");
        logger.info("Demonstrating SLF4J structured logging features");
        
        // Infinite loop with different logging examples
        while (true) {
            counter++;
            
            // Cycle through different logging examples
            int logType = counter % 12;
            
            switch (logType) {
                case 0:
                    logger.info("hello world");
                    break;
                case 1:
                    logger.error("this is at error level");
                    break;
                case 2:
                    logger.info("the answer is {}", 42);
                    break;
                case 3:
                    logger.info("hello world with obj {}", 42);
                    break;
                case 4:
                    logger.info("hello world with counter {} and obj {}", counter, 42);
                    break;
                case 5:
                    logger.info("nested object with timestamp {} and value {}", 
                               java.time.LocalDateTime.now(), 42);
                    break;
                case 6:
                    Exception simulatedError = new RuntimeException("kaboom");
                    logger.error("simulated error", simulatedError);
                    break;
                case 7:
                    appLogger.info("hello from app component!");
                    break;
                case 8:
                    dbLogger.warn("slow query detected: {} took {}ms", 
                                 "SELECT * FROM users", 250);
                    break;
                case 9:
                    apiLogger.info("API request completed: {} {} status={}", 
                                  "GET", "/api/users", 200);
                    break;
                case 10:
                    // Using MDC (Mapped Diagnostic Context) for contextual logging
                    MDC.put("requestId", "req-" + counter);
                    logger.debug("this is a debug statement with MDC context");
                    MDC.clear();
                    break;
                case 11:
                    Exception error = new RuntimeException("kaboom");
                    logger.error("error with additional context: {} {}", 
                               "additional", "information", error);
                    break;
            }
            
            // Occasionally demonstrate different log levels
            if (counter % 15 == 0) {
                logger.debug("this is a debug message with counter {}", counter);
                logger.warn("this is a warning message with counter {}", counter);
            }
            
            // Occasionally demonstrate MDC usage
            if (counter % 20 == 0) {
                MDC.put("userId", "user123");
                MDC.put("sessionId", "session456");
                logger.info("using MDC for contextual logging");
                MDC.clear();
            }
            
            // Wait 1 second before next log
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                logger.warn("Thread interrupted: {}", e.getMessage());
                break;
            }
        }
    }
} 