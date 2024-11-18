#!/bin/bash
# KLG - Microk8s installer script

echo "This will install Microk8s version 1.26, setup current user for kubes and create the alias for kubectl"
sudo snap install microk8s --classic --channel=1.26/stable
sudo usermod -a -G microk8s $SUDO_USER
sudo chown -f -R $SUDO_USER ~/.kube
sudo snap alias microk8s.kubectl kubectl
echo "logout now and back in to continue setup"
