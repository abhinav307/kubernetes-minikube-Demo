$ErrorActionPreference = 'Stop'

foreach ($command in @('docker', 'minikube', 'kubectl')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command '$command' was not found. Install it and reopen PowerShell."
    }
}

minikube start --driver=docker

Write-Host 'Building the project website image...' -ForegroundColor Cyan
docker build -t kubernetes-project-site:1.0 .

Write-Host 'Loading the image into Minikube...' -ForegroundColor Cyan
minikube image load kubernetes-project-site:1.0

Write-Host 'Deploying the website and NodePort Service...' -ForegroundColor Cyan
kubectl apply -f .\k8s\site-deployment.yaml
kubectl apply -f .\k8s\site-service.yaml
kubectl rollout status deployment/kubernetes-project-site

Write-Host "`nPods:" -ForegroundColor Green
kubectl get pods -l app=kubernetes-project-site
Write-Host "`nRun this command to open the project website:" -ForegroundColor Green
Write-Host 'minikube service kubernetes-project-site --url' -ForegroundColor Yellow
