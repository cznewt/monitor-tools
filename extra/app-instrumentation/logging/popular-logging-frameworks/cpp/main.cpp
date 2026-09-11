#include <spdlog/spdlog.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <chrono>
#include <thread>

int main() {
    auto console = spdlog::stdout_color_mt("logger");
    spdlog::set_default_logger(console);
    spdlog::set_level(spdlog::level::debug);
    spdlog::set_pattern(
        "%Y-%m-%d %H:%M:%S.%e [%^%l%$] [%n] [thread %t] [%s:%# %!] - %v"
    );

    int counter = 0;

    SPDLOG_LOGGER_INFO(console, "Starting C++ basic logging example");
    SPDLOG_LOGGER_INFO(console, "Demonstrating spdlog formatting");

    while (true) {
        counter++;
        int logType = counter % 5;

        switch (logType) {
            case 0:
                SPDLOG_LOGGER_DEBUG(console, "Basic debug message, counter: {}", counter);
                break;
            case 1:
                SPDLOG_LOGGER_INFO(console, "Information message, counter: {}", counter);
                break;
            case 2:
                SPDLOG_LOGGER_WARN(console, "Warning message, counter: {}", counter);
                break;
            case 3:
                SPDLOG_LOGGER_ERROR(console, "Error message, counter: {}", counter);
                break;
            case 4:
                SPDLOG_LOGGER_CRITICAL(console, "Critical message, counter: {}", counter);
                break;
        }

        std::this_thread::sleep_for(std::chrono::seconds(1));
    }

    return 0;
}
