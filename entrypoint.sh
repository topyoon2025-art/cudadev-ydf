#!/bin/sh
echo "Starting container ..."
service ssh restart
exec "$@"
