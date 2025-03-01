FROM openjdk:17-slim

LABEL maintainer="Bikininjas <admin@bikininja.click>"

WORKDIR /data

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl jq wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Environment variables
ENV MINECRAFT_VERSION="latest" \
    TYPE="PAPER" \
    MEMORY="1G" \
    EULA="false"

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Minecraft server port
EXPOSE 25565

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
