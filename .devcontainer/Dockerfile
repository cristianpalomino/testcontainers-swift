FROM swift:latest

# Install additional dependencies if needed
RUN apt-get update && apt-get install -y \
    lldb \
    libssl-dev \
    libcurl4-openssl-dev \
    zlib1g-dev

# Set the working directory
WORKDIR /workspace

# Copy the project files into the container
COPY . /workspace

# Run swift build to fetch dependencies
RUN swift build

# Expose necessary ports (if any)
EXPOSE 8080