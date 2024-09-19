#!/bin/bash KLG
echo "This installer is for Ubuntu only"
echo "Setup Microk8s environment - enable DNS, Storage, MetalLB"
microk8s enable dns storage metallb

echo "Extract files and create needed directories"
sudo tar -zxf sdds_v1.0.0.tar.gz -C /opt/

echo "Kubectl create namespaces and configure context"
kubectl create ns splunk
kubectl config set-context --current --namespace=splunk
kubectl config view --raw > ~/.kube/config


echo "Kubectl apply configmaps, build services and deploy 3 DS replica nodes"
kubectl apply -f /opt/sdds/yaml/configmap.yaml
kubectl apply -f /opt/sdds/yaml/lb.yaml
kubectl apply -f /opt/sdds/yaml/sdds.yaml

echo "Snap install HELM and repo for Splunk OTEL Collector in the splunk namespace"
sudo snap install helm --classic
helm repo add splunk-otel-collector-chart https://signalfx.github.io/splunk-otel-collector-chart
helm -n splunk install splunk-otel-collector --values /opt/sdds/yaml/sc4otel.yaml splunk-otel-collector-chart/splunk-otel-collector
