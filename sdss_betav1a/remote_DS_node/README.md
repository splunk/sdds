**Splunk Distributed Deployment Server / SDDS. --- Remote Node deployment**

The code below will deploy:
* 3 Splunk Deployment Server replica nodes running in a Kubernetes Deployment/Pod
* a pre-configured Load Balancer (service) running on a default inbound port TCP/32740

The Load Balancer & tcp-services configuration deploys an inbound TCP proxy on each HOST using a default port of TCP/32740
this proxy is used to communicate between each of the Splunk Deployment Server replicas on the standard management port TCP/8089

Universal Forwarders connect inbound on TCP/32740 using the standard **deploymentclient.conf** configuration:

      [target-broker:deploymentServer]
      targetUri= [HOST running DS replicas]:32740

**Pre-Requistites for a Splunk Distributed Deployment Server**

* Kubernetes 1.13+ (+DNS/+Storage)
* Clustered network support (i.e. Calico,Canal,Cilium,Flannel,Kube-ovn)
* MetalLB (https://metallb.universe.tf/) - Apache 2.0
* S3FS & S3 Bucket mounted on Host at /var/s3fs

**Remote Deployment Server node configuration**

Create a Splunk namespace & set the context

      kubectl create ns splunk
      kubectl config set-context --current --namespace=splunk

Apply the configmaps to deploy TCP services for port 8089

      kubectl apply -f configmap.yaml

Apply LB service YAML to create a proxy for HOST port tcp/32740 -> container port tcp/8089  

      kubectl apply -f lb.yaml

Pod/Deployment - 3 Splunk Deployment Server (replica) nodes with the folllowing hostPath mappings for **/var/s3fs (S3 Bucket mounted)**

      kubectl apply -f sdss_fuse.yaml

**S3 Buckets/Directories needed**

* _**deployment-apps**:_
   All apps to be deployed to UFs should be in the deployment-apps directory
  
   **Bucket:s3://<S3-BUCKET>/deployment-apps**
  
   **Host**: /var/s3fs/deployment-apps - Replica: /opt/splunk/etc/deployment-apps

*  _**serverclass.conf:**_ Global Configuration App - sdds_global_config
  
* This is where the serverclass.conf configuration will be hosted in 2 parts
  
     _default/serverclass.conf_ - has the global configuration only  
  
      [global]
      crossServerChecksum=true
      blacklist.0 = *
     
     _local/serverclass.conf_ - has all local configurations  
  
     **Bucket**:s3://<S3-BUCKET>/sdds_global_config
     **Host**: /var/s3fs/sdds_global_config - Replica: /opt/splunk/etc/apps/sdds_global_config

* _**outputs.conf:**_
  
  HEC/httpout for all _* data from DS replica nodes
  
  **Bucket**:s3://<S3-BUCKET>/sdds_outputs_config
  
  **Host**: /var/s3fs/sdds_outputs_config - Replica: /opt/splunk/etc/sdds_outputs_config
  
  _default/outputs.conf_
  
      [httpout]
      httpEventCollectorToken = <HEC token>
      uri = <HEC ENDPOINT>
      batchSize = 32768 #32kb batch size instead of 64kb default
      batchTimeout = 10 #10 second timeout instead of 30s default
 
