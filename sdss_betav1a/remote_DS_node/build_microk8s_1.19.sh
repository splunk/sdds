#!/bin/bash
echo "This installer is to setup a basic microk8s deployment"
sudo snap install microk8s --classic --channel=1.19/stable
sudo usermod -a -G microk8s splunker
sudo chown -f -R splunker ~/.kube
sudo snap alias microk8s.kubectl kubectl
echo "logout and run the mk8.sh configuration script"

