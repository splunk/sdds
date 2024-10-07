#!/bin/bash Installer Script for Splunk Distributed Deployment Server project
# Kate Lawrence-Gupta - Principal Platform Architect
# https://github.com/splunk/sdds

#Enable Microk8s DNS, Storage and MetalLB
echo "Enabling Microk8s: DNS, Storage & configuring MetalLB"
echo "..."
microk8s enable dns storage metallb

#create directories needed
echo "Creating directories: /opt/sdds and moving folders"
echo "..."
sudo mkdir /opt/sdds/
sudo mkdir /opt/sdds/deployment-apps
sudo cp -R yaml/ /opt/sdds/
sudo cp -R global-config/ /opt/sdds/

#create Kubernetes namespace called splunk ,configure overall context and set as default
echo "Creating Kubernetes: setting configurations and defaults"
echo "..."
kubectl create ns splunk
kubectl config set-context --current --namespace=splunk
kubectl config view --raw > ~/.kube/config

#apply the yaml files in the following order to create a TCP configmap
echo "Applying YAML configurations: configmap, load balancer & Splunk DS replicas"
echo "..."
kubectl apply -f ../yaml/configmap.yaml
#Load Balancer for outbound facing TCP/32740 & containers on TCP/8089
kubectl apply -f ../yaml/lb.yaml
#setup Splunk POD splunksdds - 3 replicas by default
kubectl apply -f ../yaml/sdds.yaml

#Install Helm support
echo "Install Helm: adding Splunk OTEL Collector repo and configurating with default sc4otel.yaml"
echo "..."
sudo snap install helm --classic
#Add Helm repo
helm repo add splunk-otel-collector-chart https://signalfx.github.io/splunk-otel-collector-chart
#Install Helm chart in Splunk namespace with the preconfigured sc4otel.yaml
helm -n splunk install splunk-otel-collector --values ../yaml/sc4otel.yaml splunk-otel-collector-chart/splunk-otel-collector
