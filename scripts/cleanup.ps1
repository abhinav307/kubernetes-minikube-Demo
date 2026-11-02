$ErrorActionPreference = 'Stop'

Write-Host 'Removing project Kubernetes resources...' -ForegroundColor Yellow
kubectl delete -f .\k8s\original-service.yaml --ignore-not-found
kubectl delete -f .\k8s\original-deployment.yaml --ignore-not-found
kubectl delete -f .\k8s\site-service.yaml --ignore-not-found
kubectl delete -f .\k8s\site-deployment.yaml --ignore-not-found
Write-Host 'Resources removed. The Minikube cluster is still available.' -ForegroundColor Green
