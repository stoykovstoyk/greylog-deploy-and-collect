#!/bin/bash

# Step 1: Define Docker images and container names
GRAYLOG_CONTAINER_NAME="graylog"
ELASTICSEARCH_CONTAINER_NAME="elasticsearch"
MONGO_CONTAINER_NAME="mongo"

# Step 2: Start MongoDB 5.0 container
echo "Starting MongoDB 5.0 container..."
docker run --name $MONGO_CONTAINER_NAME -d mongo:5.0
if [ $? -eq 0 ]; then
    echo "MongoDB 5.0 started successfully."
else
    echo "Failed to start MongoDB." >&2
    exit 1
fi

# Step 3: Start Elasticsearch container
echo "Starting Elasticsearch container..."
docker run --name $ELASTICSEARCH_CONTAINER_NAME -d -p 9200:9200 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.10.2
if [ $? -eq 0 ]; then
    echo "Elasticsearch started successfully."
else
    echo "Failed to start Elasticsearch." >&2
    exit 1
fi

# Step 4: Generate a random password secret for Graylog
PASSWORD_SECRET=$(openssl rand -hex 16)
echo "Generated password secret: $PASSWORD_SECRET"

# Step 5: Generate root password hash for Graylog
GRAYLOG_ROOT_PASSWORD="admin" # Change this password as desired
GRAYLOG_ROOT_PASSWORD_SHA2=$(echo -n "$GRAYLOG_ROOT_PASSWORD" | sha256sum | awk '{print $1}')
echo "Generated Graylog root password hash."

# Step 6: Start Graylog container
echo "Starting Graylog container..."
docker run --name $GRAYLOG_CONTAINER_NAME \
    --link $MONGO_CONTAINER_NAME:mongo \
    --link $ELASTICSEARCH_CONTAINER_NAME:elasticsearch \
    -e GRAYLOG_PASSWORD_SECRET=$PASSWORD_SECRET \
    -e GRAYLOG_ROOT_PASSWORD_SHA2=$GRAYLOG_ROOT_PASSWORD_SHA2 \
    -e GRAYLOG_RECEIVE_BUFFER_SIZE=1048576 \
    -p 9000:9000 \
    -p 5555:5555 \
    -d graylog/graylog:5.1

if [ $? -eq 0 ]; then
    echo "Graylog started successfully."
else
    echo "Failed to start Graylog." >&2
    exit 1
fi

# Step 7: Output success message
echo "Graylog, Elasticsearch, and MongoDB 5.0 containers are running."
echo "You can access Graylog at: http://localhost:9000"

