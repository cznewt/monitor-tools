#!/usr/bin/env node

// Pino's primary usage writes ndjson to `stdout`:
const pino = require('pino')()

// However, if "human readable" output is desired,
// `pino-pretty` can be provided as the destination
// stream by uncommenting the following line in place
// of the previous declaration:
// const pino = require('pino')(require('pino-pretty')())

let counter = 0;

pino.info('Starting JavaScript basic logging example with Pino');
pino.info('Demonstrating various Pino logging features');

// Create child loggers with different contexts
const appLogger = pino.child({ component: 'app' });
const dbLogger = pino.child({ component: 'database' });
const apiLogger = pino.child({ component: 'api', version: '1.0' });

// Function to demonstrate various logging features
function logMessage() {
    counter++;
    
    // Cycle through different logging examples
    const logType = counter % 12;
    
    switch (logType) {
        case 0:
            pino.info('hello world');
            break;
        case 1:
            pino.error('this is at error level');
            break;
        case 2:
            pino.info('the answer is %d', 42);
            break;
        case 3:
            pino.info({ obj: 42 }, 'hello world');
            break;
        case 4:
            pino.info({ obj: 42, counter: counter }, 'hello world with counter');
            break;
        case 5:
            pino.info({ nested: { obj: 42, timestamp: new Date() } }, 'nested object');
            break;
        case 6:
            pino.error(new Error('simulated error'));
            break;
        case 7:
            appLogger.info('hello from app component!');
            break;
        case 8:
            dbLogger.warn({ query: 'SELECT * FROM users', duration: 250 }, 'slow query detected');
            break;
        case 9:
            apiLogger.info({ method: 'GET', path: '/api/users', status: 200 }, 'API request completed');
            break;
        case 10:
            const tempChild = pino.child({ requestId: `req-${counter}` });
            tempChild.debug('this is a debug statement via child');
            break;
        case 11:
            pino.info(new Error('kaboom'), 'with', 'additional', 'context');
            break;
    }
    
    // Occasionally demonstrate level changes
    if (counter % 20 === 0) {
        pino.level = 'debug';
        pino.debug('switched to debug level - this should now be visible');
        setTimeout(() => {
            pino.level = 'info';
            pino.info('switched back to info level');
        }, 500);
    }
    
    // Occasionally demonstrate trace level
    if (counter % 25 === 0) {
        const originalLevel = pino.level;
        pino.level = 'trace';
        pino.trace('this is a trace statement');
        pino.level = originalLevel;
    }
}

// Log every 1 second infinitely
setInterval(logMessage, 1000); 