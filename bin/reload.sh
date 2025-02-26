echo "Scale DS replicas to 0"
kubectl scale --replicas=0 -f /opt/sdds/yaml/sdds.yaml
sleep 2s
echo "..."
kubectl scale --replicas=3 -f /opt/sdds/yaml/sdds.yaml
sleep 2s
echo "Scale DS replicas to 3"
kubectl get pods
