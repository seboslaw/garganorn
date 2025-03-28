FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Install DuckDB CLI
RUN curl -L https://github.com/duckdb/duckdb/releases/download/v0.9.2/duckdb_cli-linux-aarch64.zip -o duckdb_cli.zip \
    && unzip duckdb_cli.zip \
    && mv duckdb /usr/local/bin/ \
    && rm duckdb_cli.zip

# Copy project files
COPY pyproject.toml .
COPY garganorn/ garganorn/
COPY scripts/ scripts/

# Make startup script executable
RUN chmod +x scripts/start.sh

# Install Python dependencies
RUN pip install --no-cache-dir .

# Create directory for database
RUN mkdir -p /app/db

# Expose the port the server runs on
EXPOSE 5001

# Command to run the startup script
CMD ["./scripts/start.sh"] 