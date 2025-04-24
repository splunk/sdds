## What is the Splunk Distributed Deployment Server (SDDS) project?

Splunk Distributed Deployment Server (SDDS) is a model to build a more scalable Splunk Deployment Server ((https://docs.splunk.com/Documentation/Splunk/8.2.6/Updating/Planadeployment)) using a Kubernetes framework to host multiple Splunk DS replicas on the same instance; a custom Load Balancer handles the incoming traffic (https://metallb.universe.tf/)

- Testing has been show SDDS to be able to host 25k+ nodes per instance; the current recommendation is 10k
- SDDS maximizes the DS single threadeded functions & incoming TCP connections more efficiently. 

**Additionally SDDS has the:**
- ability to support older clients who don't send client-header data with each DS transaction
- reduce TCP footprint for MITM attack posture on unecrypted/unauthenticated endpoints
- supports multiple Splunk versions 
- encrypted by default with a restmap.conf configuration

SDDS can be deployed & scaled by either:
 - adding new nodes 
 - scaling replicas

SDDS 1.0.0 has been tested on the following platform:
 - Ubuntu 22.04 w/ snap
 - Microk8s 1.32 
 - Splunk 9.0+

**Updated Topologies** (see Topology Diagram)
- **Recommendation**  - Splunk does not recommend hosting a Deployment Server along an edge network due to the lack of proper token authentication and basic encryption in addition to the open TCP port requirement
- **VPN Configuration**  - if Universal Forwarders are connecting to Internal networks using TCP enabled bi-direction VPN; then the Internal DS nodes can be used.
- **Alternate Configuration** - if Universal Forwarders are on an External network with no TCP connectivity to Internal DS nodes; then a separate DS node can be deployed in either a Layer2/3 network accessible instance to the Univseral Forwarders in that subnet.
 - - The SDDS node in this configuration should continue to send monitoring data through HEC allowing for passive monitoring of remote DS nodes.

**A Splunk Monitoring Console app (sddsmc.tar.gz) is provided with the following:**
 - indexes.conf - defines the sdds_events, sdds_metrics & sdds_history(summary) indexes
 - inputs.conf - HEC inputs for OTEL collector
 - savedsearches.conf - enables collection of client history with sdds_history summary index to keep track of clients, clients and apps on a 5 minute interval
 - app/sddsmc/mc.xml - Monitoring Console view for status and historical tracking of DS activity

**How to Install a Deployment Server node**

The  setup runs in 4 steps:
 1. Clone this repo
 2. Run the bin/microk8s_installer.sh to setup Microk8s deployment
 3. Logout and back into the host
 4. Continue the installation by logging back in and using the bin/setup_sdds.sh script for the final setup

**Configuration notes**
the **outputs.conf** & **sc4otel.yaml** files will need to be updated for the appropriate indexers/HEC destinations

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
   - global_config/default/optional-server.conf >> SPLUNK_HOME/etc/global_config/default
     - if you have a previously set pass4symmkey for the UFs you will need to set that key in this apps server.conf file to avoid 401 errors
