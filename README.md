# Graylog Docker Deployment and Log Sending

This repository contains two Bash scripts for deploying Graylog with its dependencies (MongoDB and Elasticsearch) in Docker containers, as well as for sending logs to Graylog.

## Scripts Overview

### 1. `deploy_graylog.sh`
This script automates the process of deploying Graylog, Elasticsearch, and MongoDB containers in Docker. It sets up the necessary services and configures Graylog with a password secret and root password hash.

### 2. `sent_logs.sh`
This script is responsible for sending logs from the `/var/log` directory to Graylog. It can send the entire log file initially and follow new lines in real-time to continuously send logs as they are written.

---

## Prerequisites

- Docker must be installed and running on the host machine.
- The server should have access to the internet to pull Docker images.
- You must have permission to access and read log files in the `/var/log` directory.
- Ensure that the server running Graylog can accept logs on the specified port (default: 5555).

---

## Usage Instructions

### Step 1: Deploy Graylog, Elasticsearch, and MongoDB

To deploy Graylog, MongoDB, and Elasticsearch in Docker containers, run the following command:

```bash
./deploy_graylog.sh
```

#### This script will:

    Start the MongoDB 5.0 container.
    Start the Elasticsearch container on port 9200 and configure it as a single-node cluster.
    Generate a password secret for Graylog and a root password hash.
    Start the Graylog container, link it to MongoDB and Elasticsearch, and expose Graylog on port 9000 (for web access) and port 5555 (for receiving log messages).

Once the script finishes, Graylog will be accessible at http://localhost:9000.
Default credentials are: 
u: admin
p: admin

### Step 2: Send Logs to Graylog

To start sending logs from the /var/log directory to Graylog, run:

```bash
./sent_logs.sh
```
### This script will:

    Loop through each log file in the /var/log directory and send its contents to Graylog.
    It sends the entire content of each log file once and continuously sends new log lines as they are added using tail -F.
    It stores a marker file in /tmp/sent_logs to ensure logs are not sent multiple times.

The logs are sent to Graylog using the TCP input on port 5555. You can adjust the log directory or port if necessary in the script.
Optional Configuration

    Graylog Port: The default Graylog input port in sent_logs.sh is 5555. If your Graylog setup uses a different port, modify the GRAYLOG_PORT variable in the script.
    Log Directory: The script sends logs from the /var/log directory by default. If you want to send logs from a different location, modify the LOG_DIR variable.

### Troubleshooting

    If the containers fail to start, ensure that Docker is running and the ports are not being used by other services.
    Make sure the required ports (e.g., 9200, 9000, and 5555) are open and not blocked by a firewall.
    If the logs are not appearing in Graylog, verify that the sent_logs.sh script is correctly sending logs by checking the Graylog input configuration and network connectivity.

### License

This project is licensed under the MIT License - see the LICENSE file for details.


This `README.md` file provides a detailed explanation of how to use your two Bash scripts, deploy the necessary services, and send logs to Graylog. You can customize or expand it as needed.