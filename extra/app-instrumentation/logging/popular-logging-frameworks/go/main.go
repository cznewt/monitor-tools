package main

import (
	"errors"
	"time"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

func main() {
	// Configure Zap logger for JSON output to stdout
	config := zap.NewProductionConfig()
	config.Level = zap.NewAtomicLevelAt(zap.DebugLevel)
	config.OutputPaths = []string{"stdout"}

	logger, err := config.Build()
	if err != nil {
		panic(err)
	}
	defer logger.Sync()

	// Create child loggers for different components
	appLogger := logger.Named("app")
	dbLogger := logger.Named("database")
	apiLogger := logger.Named("api")

	counter := 0

	appLogger.Info("Starting Go basic logging example with Zap")
	appLogger.Info("Demonstrating Zap structured logging features")

	// Infinite loop with different logging examples
	for {
		counter++

		// Cycle through different logging examples
		logType := counter % 12

		switch logType {
		case 0:
			appLogger.Info("hello world")
		case 1:
			appLogger.Error("this is at error level")
		case 2:
			appLogger.Info("the answer is 42", zap.Int("answer", 42))
		case 3:
			appLogger.Info("hello world", zap.Int("obj", 42))
		case 4:
			appLogger.Info("hello world with counter",
				zap.Int("obj", 42),
				zap.Int("counter", counter))
		case 5:
			appLogger.Info("nested object",
				zap.Object("nested", zapcore.ObjectMarshalerFunc(func(enc zapcore.ObjectEncoder) error {
					enc.AddInt("obj", 42)
					enc.AddTime("timestamp", time.Now())
					return nil
				})))
		case 6:
			appLogger.Error("simulated error", zap.Error(errors.New("kaboom")))
		case 7:
			appLogger.Info("hello from app component!")
		case 8:
			dbLogger.Warn("slow query detected",
				zap.String("query", "SELECT * FROM users"),
				zap.Duration("duration", 250*time.Millisecond))
		case 9:
			apiLogger.Info("API request completed",
				zap.String("method", "GET"),
				zap.String("path", "/api/users"),
				zap.Int("status", 200))
		case 10:
			tempChild := appLogger.With(zap.String("requestId", "req-"+string(rune(counter))))
			tempChild.Debug("this is a debug statement via child")
		case 11:
			appLogger.Error("error with additional context",
				zap.Error(errors.New("kaboom")),
				zap.String("context1", "additional"),
				zap.String("context2", "information"))
		}

		// Occasionally demonstrate sugar logger
		if counter%15 == 0 {
			sugar := logger.Sugar()
			sugar.Infow("using sugar logger",
				"counter", counter,
				"feature", "sugar")
		}

		// Occasionally demonstrate different log levels
		if counter%20 == 0 {
			appLogger.Debug("this is a debug message", zap.Int("counter", counter))
			appLogger.Warn("this is a warning message", zap.Int("counter", counter))
		}

		// Wait 1 second before next log
		time.Sleep(1 * time.Second)
	}
}
