$ErrorActionPreference = 'Stop'

foreach ($command in @('docker', 'minikube', 'kubectl')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command '$command' was not found. Install it and reopen PowerShell."
    }
}

Write-Host 'Starting Minikube with Docker driver...' -ForegroundColor Cyan
minikube start --driver=docker

Write-Host 'Applying the Nginx Deployment and NodePort Service...' -ForegroundColor Cyan
kubectl apply -f "$PSScriptRoot/../k8s/original-deployment.yaml"
kubectl apply -f "$PSScriptRoot/../k8s/original-service.yaml"

Write-Host 'Waiting for the Deployment...' -ForegroundColor Cyan
kubectl rollout status deployment/nginx-demo

Write-Host "`nPods:" -ForegroundColor Green
kubectl get pods -l app=nginx-demo
Write-Host "`nService:" -ForegroundColor Green
kubectl get services nginx-demo
Write-Host "`nOpen the application using this URL command:" -ForegroundColor Green
Write-Host 'minikube service nginx-demo --url' -ForegroundColor Yellow
