**Splunk Distributed Deployment Server (SDDS) Project**


**What is Splunk Distributed Deployment Server/SDDS?**

SDDS is a standardized model used to build a repeatable and scalable deployment of Splunk Deployment Server (https://docs.splunk.com/Documentation/Splunk/8.2.6/Updating/Planadeployment)

SDDS can be easily deployed & scaled by adding "Remote" Deployment Server nodes while monitored from a central location (Monitoring Console).

SDDS examples will default to **Splunk version 8.2** however additional deployment example yamls & restmap.conf are available for Splunk 9.0 see the [Instructions to setup a remote DS nodes]([https://github.com/klawrencegupta-splunk/sdds/tree/main/sdss_betav1a/remote_DS_node](https://github.com/splunk/sdds/tree/main/sdss_betav1a/remote_DS_node)) for more details on the differences.

**SDDS has 3 components**

- "Remote" Deployment Server nodes   - [Instructions to setup a remote DS nodes](https://github.com/splunk/sdds/tree/main/sdss_betav1a/remote_DS_node)


  - Splunk is deployed in a Kubernetes Pod a set of 3 Splunk "replicas" or copies of Splunk Deployment Server all hosting the same configurations.
  - These Pod(s) are what Universal Forwarders will use as the 
    - **targetUri** in the deploymentclient.conf [https://docs.splunk.com/Documentation/Splunk/8.2.6/Admin/Deploymentclientconf] that connect the UF to the Splunk Deployment Server
    - Artifacts
      1. **configmap.yaml** - TCP Services for port/8089
      2. **lb.yaml** - MetalLB [https://metallb.universe.tf/] load-balancer service configuration that standardizes the sessionAffinity to the ClientIP of the incoming connection
      3. **sdss_fuse.yaml** - Pod/Deployment of 3 Splunk replicas configured as Deployment Servers

  - All **serverclass.conf** & **deployment-apps** configurations [https://docs.splunk.com/Documentation/Splunk/8.2.6/Admin/Serverclassconf]
    - any local path or NFS or FUSE mount **default path is /var/s3fs
    - are hosted on an S3 Bucket (https://aws.amazon.com/s3/)  
    

- [Splunk Connect 4 Kubernetes](https://github.com/splunk/splunk-connect-for-kubernetes) SC4K_values.yaml 
  - SDDS uses Splunk Connect for Kubernetes to collect data through the Splunk HTTP Event Collector [https://docs.splunk.com/Documentation/Splunk/8.2.6/Data/UsetheHTTPEventCollector] 
    - sdds_events - index for event data Kubernetes Pod, namespace, and container level data
    - sdds_metrics - index for metrics related to Kubernetes Pod CPU and Memory utilization data
- **SDDS Monitoring Console** app (SPL) [sdds_monitoring.spl](https://github.com/splunk/sdds/tree/main/sdss_betav1a/sdds_monitoring)]
  - **Dashboards** 
    - <u>Monitoring Console (Home)</u>
      - Deployment Server Host/Replica metrics
      - CPU/Memory Utilization
      - SDDS
        - checksum tracking
        - Handshakes/Negotiations
        - UF Download/Installation Metrics
    - <u>Kubernetes: Extended Metrics</u> 
      - CPU Utilization over time by host, namespace & replicas
    - <u>SDDS: Extended Metrics</u> 
      - Metric tracking over time for UF Handshakes, Downloads, Installs - OK & Failures


[Splunk Distributed Deployment Server --- Topology.png] SDDS Topology
