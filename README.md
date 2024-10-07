## What is the Splunk Distributed Deployment Server (SDDS) project?

SDDS is a model to build a more scalable Splunk Deployment Server by using a Kubernetes framework to create Splunk DS as replicas to service clients faster on the same compute footprint (https://docs.splunk.com/Documentation/Splunk/8.2.6/Updating/Planadeployment)

SDDS can be deployed & scaled by either:
 - adding new nodes 
 - scaling replicas

SDDS 1.0.0 has been tested on the following platform:
 - Ubuntu 22.04 w/ snap
 - Microk8s 1.26 
 - Splunk 9.0+

**How to Install**

The  setup runs in 4 steps:
 1. Clone this repo
 2. Run the bin/microk8s_installer.sh to setup Microk8s deployment
 3. Logout and back into the host
 4. Continue the installation by logging back in and using the bin/setup_sdds.sh script for the final setup

**bin/microk8s_installer.sh**
 - an installer script to setup [Microk8s](https://microk8s.io/) from the default SNAP repo
 - You will be prompted to logout and back into the instance to finish configuration

**bin/setup_sdds.sh**
 - This script will enable Microk8s with the default storage, DNS
 - MetalLB will prompt for network it should use:  **chose first network range presented this is the default local network to the instance** 
 - Create the main directory /opt/sdds +  bin, yaml, global_config & deployment-apps
 - Creates a new namespace called splunk & sets defaults
 - Apply the following YAML
   - **yaml/configmap.yaml** - TCP Services for port/8089
   - **yaml/lb.yaml** - MetalLB [https://metallb.universe.tf/] load-balancer service configuration that standardizes the sessionAffinity to the ClientIP of the incoming connection
   - **yaml/sdss.yaml** - Pod/Deployment of 3 Splunk replicas configured as Deployment Servers
 - Install Helm (SNAP) & add/run the [Splunk OTEL Collector](https://github.com/signalfx/splunk-otel-collector) with the provided **sc4otel.yaml **
 
**These following local sub-directories will map to the DS containers at these locations:**
   - deployment-apps/ >> $SPLUNK_HOME/etc/deployment-apps
   - global_config/default/outputs.conf >> $SPLUNK_HOME/etc/global_config/default
   - global_config/default/restmap.conf >> SPLUNK_HOME/etc/global_config/default
   - global_config/default/serverclass.conf >> SPLUNK_HOME/etc/global_config/default

**Configuration notes**
the **outputs.conf** & **sc4otel.yaml** files will need to be updated for the appropriate indexers/HEC destinations
