#!/bin/bash
echo "Starting new container..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth
docker pull 367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth:latest
docker run -d -p 80:3000 --restart always --name my-static-container 367260454855.dkr.ecr.us-east-1.amazonaws.com/devops/ananth:latest

