#!/usr/bin/env python3

import logging
import time

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format= '%(asctime)s - %(filename)s:%(lineno)d - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
    ]
)

logger = logging.getLogger(__name__)

def main():
    counter = 0
    
    logger.info("Starting Python basic logging example")
    logger.info("Demonstrating Python logging module")
    
    # Infinite loop with different log levels
    while True:
        counter += 1
        
        # Cycle through different log levels
        log_type = counter % 5
        
        if log_type == 0:
            logger.debug(f"Basic debug message, counter: {counter}")
        elif log_type == 1:
            logger.info(f"Information message, counter: {counter}")
        elif log_type == 2:
            logger.warning(f"Warning message, counter: {counter}")
        elif log_type == 3:
            logger.error(f"Error message, counter: {counter}")
        elif log_type == 4:
            logger.critical(f"Critical message, counter: {counter}")
        
        # Wait 1 second before next log
        time.sleep(1)

if __name__ == "__main__":
    main() 