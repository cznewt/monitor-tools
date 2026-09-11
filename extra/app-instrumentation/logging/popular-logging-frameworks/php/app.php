<?php

require_once 'vendor/autoload.php';

use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use Exception;

// Create the main logger
$logger = new Logger('app');

// Create a console handler that writes to stdout
$consoleHandler = new StreamHandler('php://stdout', Logger::DEBUG);

// Push the handler onto the logger
$logger->pushHandler($consoleHandler);

// Add a processor to inject an 'environment' extra field into every log entry
$logger->pushProcessor(function ($record) {
    $record['extra']['environment'] = 'production'; // You can set any value or use getenv() etc.
    return $record;
});

// Create component-specific loggers if you want
$appLogger = $logger->withName('app');
$dbLogger = $logger->withName('database');
$apiLogger = $logger->withName('api');

$counter = 0;

$logger->info("Starting PHP basic logging example with Monolog");
$logger->info("Demonstrating Monolog structured logging features");

while (true) {
    $counter++;
    $logType = $counter % 6;

    switch ($logType) {
        case 0:
            $logger->info("hello world");
            break;
        case 1:
            $logger->error("this is at error level");
            break;
        case 2:
            $logger->info("hello world with counter", [
                'counter' => $counter,
                'obj' => 42
            ]);
            break;
        case 3:
            $dbLogger->warning("slow query detected", [
                'query' => 'SELECT * FROM users',
                'duration' => 250
            ]);
            break;
        case 4:
            $apiLogger->info("API request completed", [
                'method' => 'GET',
                'path' => '/api/users',
                'status' => 200
            ]);
            break;
        case 5:
            // Fatal error with stack trace
            $fatalException = new Exception("Critical system failure - database connection lost");
            $logger->emergency("System encountered a fatal error", [
                'exception' => $fatalException,
                'error_code' => 'DB_CONNECTION_LOST',
                'affected_service' => 'user_authentication'
            ]);
            break;
    }

    // Wait 1 second before next log
    sleep(1);
}
