#!/bin/sh
echo "Starting setup..."
sudo cos-extensions install gpu 
sudo mount --bind /var/lib/nvidia /var/lib/nvidia 
sudo mount -o remount,exec /var/lib/nvidia
/var/lib/nvidia/bin/nvidia-smi
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
echo "Finishing setup..."
