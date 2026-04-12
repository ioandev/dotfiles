#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing .NET SDK 8 and 10..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    yay -S --noconfirm dotnet-sdk-8.0 aspnet-runtime-8.0 dotnet-sdk-10.0 aspnet-runtime-10.0
else
    wget -q "https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb" -O /tmp/packages-microsoft-prod.deb
    sudo dpkg -i /tmp/packages-microsoft-prod.deb
    rm /tmp/packages-microsoft-prod.deb
    sudo apt update
    sudo apt install -y dotnet-sdk-8.0 aspnet-runtime-8.0 dotnet-sdk-10.0 aspnet-runtime-10.0
fi

echo "Updating .NET workloads..."
sudo dotnet workload update

echo ".NET SDK 8 and 10 installation complete!"
