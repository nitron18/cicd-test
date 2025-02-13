#!/bin/bash
echo "Stopping old container..."
docker stop my-static-container || true
docker rm my-static-container || true

