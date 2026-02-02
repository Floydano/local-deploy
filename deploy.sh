#!/bin/bash

# Despliega el controlador de Ingress NGINX (si no está instalado)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml

# Espera a que el controlador esté listo
kubectl wait --for=condition=available --timeout=300s deployment/ingress-nginx-controller -n ingress-nginx

# Elimina el webhook de validación para evitar errores en entornos locales
kubectl delete validatingwebhookconfigurations ingress-nginx-admission --ignore-not-found=true

# Aplica los archivos
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
kubectl apply -f apache-deployment.yaml
kubectl apply -f apache-service.yaml
kubectl apply -f nginx-ingress.yaml
echo "Despliegue completado. Verifica con kubectl get ingress"
