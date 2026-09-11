# App Instrumentation - Structured Logging with Alloy Parsing

This directory contains a comprehensive **Alloy tutorial** demonstrating how to parse structured logs from 7 popular programming languages using modern logging frameworks. Each language uses industry-standard structured logging libraries, and all logs are processed through a unified Alloy pipeline for collection, parsing, and storage in Loki.

## 🎯 Tutorial Objectives

- **Learn Alloy log parsing**: Understand how to parse different log formats using `loki.process` stages
- **Multi-language support**: Handle logs from 7 different programming languages in a single pipeline
- **Structured logging**: Demonstrate modern logging practices with structured data
- **Real-world scenarios**: Show practical log parsing for containerized applications

## Languages and Modern Logging Frameworks

| Language | Logging Framework | Type | Key Features | Docker Base Image |
|----------|------------------|------|--------------|-------------------|
| **JavaScript** | `Pino` | JSON structured | High performance, child loggers, ndjson output | `node:22-alpine` |
| **Python** | `logging` module | Structured text | Built-in standard library with custom formatting | `python:3.12-slim` |
| **Java** | `SLF4J + Logback` | Structured text | Parameterized messages, MDC context, thread info | `openjdk:26-slim` |
| **C#** | `Microsoft.Extensions.Logging` | Structured text | .NET standard framework, event IDs, structured data | `mcr.microsoft.com/dotnet/*:9.0` |
| **C++** | `spdlog` | Structured text | High performance, source location, thread-safe | `ubuntu:24.04` |
| **Go** | `Zap` | JSON structured | High performance, named loggers, structured fields | `golang:1.23-alpine` |
| **PHP** | `Monolog` | Structured text | Context arrays, processors, multiple handlers | `php:8.3-cli-alpine` |

## Directory Structure

```
app-instrumentation/logging/popular-logging-frameworks/
├── alloy/
│   ├── config.alloy          # Main Alloy configuration
│   └── helper.alloy           # Language-specific log parsers
├── javascript/
│   ├── app.js                 # Pino structured logging
│   └── Dockerfile
├── python/
│   ├── app.py                 # Python logging with custom format
│   └── Dockerfile
├── java/
│   ├── App.java               # SLF4J + Logback
│   ├── logback.xml
│   └── Dockerfile
├── csharp/
│   ├── Program.cs            # Microsoft.Extensions.Logging
│   ├── LoggingExample.csproj
│   └── Dockerfile
├── cpp/
│   ├── main.cpp              # spdlog structured logging
│   ├── CMakeLists.txt
│   └── Dockerfile
├── go/
│   ├── main.go               # Zap JSON logging
│   ├── go.mod
│   ├── go.sum
│   └── Dockerfile
├── php/
│   ├── app.php               # Monolog with context
│   └── Dockerfile
├── docker-compose.yml         # Complete stack with Loki + Grafana
├── loki-config.yaml
└── README.md
```

## 🔍 Alloy Parsing Features Demonstrated

### Core Alloy Components Used
- **`loki.source.docker`**: Automatic Docker container log discovery
- **`loki.process`**: Multi-stage log parsing pipeline
- **`discovery.docker`**: Container metadata extraction
- **`discovery.relabel`**: Label transformation and routing

### Advanced Parsing Techniques
Each language parser demonstrates different Alloy parsing capabilities:

- **Regex parsing** (`stage.regex`): Extract structured fields from text logs
- **JSON parsing** (`stage.json`): Handle native JSON log formats  
- **Multiline handling** (`stage.multiline`): Process stack traces and exception logs
- **Label management** (`stage.labels`): Efficient indexing for filtering
- **Structured metadata** (`stage.structured_metadata`): Searchable non-indexed data
- **Timestamp parsing** (`stage.timestamp`): Multiple timestamp format support
- **Template formatting** (`stage.template`): Custom output formatting
- **Conditional logic**: Level conversion, error prioritization

### Language-Specific Parsing Examples

| Language | Primary Challenge | Alloy Solution |
|----------|------------------|----------------|
| **JavaScript (Pino)** | JSON numeric levels | Template stage for level conversion |
| **Python** | Custom text format | Regex extraction with line numbers |
| **Java (Logback)** | Multi-line stack traces | Multiline stage + regex parsing |
| **C#** | Event IDs and namespaces | Regex parsing with structured metadata |
| **C++** | Source location details | Complex regex for file:line extraction |
| **Go (Zap)** | Unix timestamps | Timestamp parsing with fractional seconds |
| **PHP (Monolog)** | Nested JSON context | Multiple JSON parsing stages |

## 🚀 Quick Start Tutorial

### Step 1: Clone the Repository

```bash
git clone https://github.com/grafana/alloy-scenarios.git
cd app-instrumentation/logging/popular-logging-frameworks
```

### Step 2: Launch the Complete Stack

```bash
# Build and run all applications with Alloy + Loki + Grafana
docker compose up --build

# Run in detached mode to see clean output
docker compose up --build -d
```

This starts:
- **7 language applications** generating structured logs
- **Alloy** parsing and forwarding logs to Loki
- **Loki** storing parsed logs with labels and metadata
- **Grafana** for log visualization and querying

### Step 3: Explore the Logs

- Head to http://localhost:3000/a/grafana-lokiexplore-app to see the logs in Grafana
- Each language has its own service name / app so you can identify which languge you would like to see the parsed logs for

## 📚 Learning Outcomes

After completing this tutorial, you'll understand:

### Alloy Concepts
- **Multi-stage processing**: How to chain `loki.process` stages for complex parsing
- **Component composition**: Using `import.file` to modularize configurations
- **Discovery patterns**: Automatic service discovery with Docker integration
- **Label vs. metadata strategy**: When to use indexed labels vs. structured metadata

### Log Parsing Techniques
- **Regex mastery**: Complex pattern matching for text log formats
- **JSON handling**: Extracting nested fields from structured logs
- **Timestamp parsing**: Supporting multiple timestamp formats across languages
- **Multiline processing**: Handling stack traces and exception logs
- **Conditional formatting**: Template logic for log transformation

### Real-World Patterns
- **Language-specific challenges**: Understanding unique parsing requirements per language
- **Performance considerations**: Efficient labeling and metadata strategies
- **Observability best practices**: Structured logging principles across tech stacks
- **Container log collection**: Production-ready log aggregation patterns

## 🔧 Configuration Details

### Language-Specific Parsing Challenges

Each language presents unique parsing requirements:

#### JavaScript (Pino)
```alloy
// Challenge: Numeric log levels (10, 20, 30, 40, 50, 60)
stage.template {
  source = "level"
  template = "{{- if eq .level_num \"30\" -}}info{{- else if eq .level_num \"50\" -}}error{{- end -}}"
}
```

#### Java (Logback)  
```alloy
// Challenge: Multi-line stack traces
stage.multiline {
  firstline = "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}"
}
```

#### Go (Zap)
```alloy
// Challenge: Unix timestamp with fractional seconds
stage.timestamp {
  source = "ts"
  format = "1750342991.0445938"
}
```