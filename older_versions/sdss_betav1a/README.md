SDDS Monitoring uses data from the [Splunk Connect for Kubernetes](https://splunkbase.splunk.com/app/4497/) for monitoring hosts, replicas and utilization

More info on Splunk Connect for Kubernetes is available at https://github.com/splunk/splunk-connect-for-kubernetes

You may need to enable the following to enable the following kubectl configuration.

      kubectl config view --raw > ~/.kube/config

The configuration below requires:

 - HEC Endpoint/Port configuration info
 - 2 HEC tokens
 - 2 Indexes (sdds_events & sdds_metrics)

These configurations are provided in the <TBD> app, but can also be setup manually using the parameters below.

      #Splunk Connect for Kubernets Values.yaml configuration for SDDS_events and SDDS_metrics
          global:
            logLevel: info
            splunk:
              hec:
                host: <HEC HOST>
                port: <HEC PORT>
                token: <HEC TOKEN>
                protocol: https
                insecureSSL: true
            kubernetes:
              clusterName: "sddsPod"
              openshift: true
          splunk-kubernetes-logging:
            enabled: true
            logLevel: info
            splunk:
              hec:
                indexName: sdds_events
            containers:
              logFormatType: cri
              logFormat: "%Y-%m-%dT%H:%M:%S.%N%:z"
            journalLogPath: /var/log/journal

          splunk-kubernetes-metrics:
            kubernetes:
              insecureSSL: true 

            # RBAC is disabled
            rbac:
              create: false

            # do not create service account
            serviceAccount:
              create: false

            splunk:
              hec:
                token: <HEC TOKEN>
                host: <HEC HOST>
                port: <HEC PORT>
                protocol: https
                indexName: sdds_metrics
                # connection to splunk is insecure
                insecureSSL: true
