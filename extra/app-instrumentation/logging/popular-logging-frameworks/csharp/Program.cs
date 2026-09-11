using Microsoft.Extensions.Logging;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using System.Threading.Tasks;

namespace LoggingExample
{
    class Program
    {
        private static ILogger<Program>? _logger;

        static async Task Main(string[] args)
        {
            // Configure logging with proper formatting
            using var host = Host.CreateDefaultBuilder(args)
                .ConfigureLogging(logging =>
                {
                    logging.ClearProviders();
                    logging.AddConsole(options =>
                    {
                        options.TimestampFormat = "yyyy-MM-dd HH:mm:ss.fff ";
                        options.IncludeScopes = false;
                    });
                    logging.SetMinimumLevel(LogLevel.Debug);
                })
                .Build();

            _logger = host.Services.GetRequiredService<ILogger<Program>>();

            int counter = 0;

            _logger.LogInformation("Starting C# basic logging example");
            _logger.LogInformation("Demonstrating Microsoft.Extensions.Logging");

            // Infinite loop with different log levels
            while (true)
            {
                counter++;

                // Cycle through different log levels
                int logType = counter % 5;

                switch (logType)
                {
                    case 0:
                        _logger.LogDebug("Basic debug message, counter: {Counter}", counter);
                        break;
                    case 1:
                        _logger.LogInformation("Information message, counter: {Counter}", counter);
                        break;
                    case 2:
                        _logger.LogWarning("Warning message, counter: {Counter}", counter);
                        break;
                    case 3:
                        _logger.LogError("Error message, counter: {Counter}", counter);
                        break;
                    case 4:
                        _logger.LogCritical("Critical message, counter: {Counter}", counter);
                        break;
                }

                // Wait 1 second before next log
                await Task.Delay(1000);
            }
        }
    }
} 