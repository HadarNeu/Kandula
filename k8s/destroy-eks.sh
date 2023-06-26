#!/bin/bash
# deploy kandula
kubectl delete -f deployment-kandula.yaml

# create LoadBalancer for Kandula
kubectl delete -f lb-service-kandula.yaml

# deleting NS so there's no resources left
kubectl delete -f kandula-ns.yaml


