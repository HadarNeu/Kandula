#!/bin/bash

# Create kandula namespace
kubectl apply -f kandula-ns.yaml

# deploy kandula
kubectl apply -f deployment-kandula.yaml

# create LoadBalancer for Kandula
kubectl apply -f lb-service-kandula.yaml

