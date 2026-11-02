# kubernetes-minikube-Demo

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.37-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Minikube](https://img.shields.io/badge/Minikube-v1.39-1B6AC6?logo=minikube&logoColor=white)](https://minikube.sigs.k8s.io/)
[![Docker](https://img.shields.io/badge/Docker-Desktop-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Nginx](https://img.shields.io/badge/Nginx-1.27--Alpine-009639?logo=nginx&logoColor=white)](https://nginx.org/)
[![Platform](https://img.shields.io/badge/Platform-Windows%2011%20%7C%20PowerShell-0078D4)](https://microsoft.com)

> **Program 12 — Cloud Computing & DevOps Lab**  
> A comprehensive, reproducible implementation demonstrating how to build, containerize, deploy, expose, and scale web applications on a local single-node Kubernetes cluster using **Minikube** and **Docker Desktop**.

---

## 📑 Table of Contents

- [Overview & Objectives](#-overview--objectives)
- [Architecture & Key Concepts](#-architecture--key-concepts)
- [Project Directory Structure](#-project-directory-structure)
- [Prerequisites & System Setup](#-prerequisites--system-setup)
- [Quick Start Guide](#-quick-start-guide)
- [Deployment Option A: Original Nginx Lab](#-deployment-option-a-original-nginx-lab)
  - [Declarative Deployment (Recommended)](#1-declarative-deployment-recommended)
  - [Imperative Command Sequence](#2-imperative-command-sequence)
  - [Scaling the Deployment](#3-scaling-the-deployment)
- [Deployment Option B: Custom Containerized Project Website](#-deployment-option-b-custom-containerized-project-website)
  - [Build and Load the Image](#1-build-and-load-the-image)
  - [Deploy Manifests](#2-deploy-manifests)
- [Deployment Option C: Standalone Local Preview](#-deployment-option-c-standalone-local-preview)
- [Cluster Networking & Windows Port-Forwarding](#-cluster-networking--windows-port-forwarding)
- [Verification & Observability Commands](#-verification--observability-commands)
- [Troubleshooting & FAQs](#-troubleshooting--faqs)
- [Resource Teardown & Cleanup](#-resource-teardown--cleanup)
- [GitHub Repository Setup](#-github-repository-setup)

---

## 🎯 Overview & Objectives

The primary objective of this project is to provide a complete, hands-on demonstration of container orchestration concepts using Kubernetes:

1. **Containerization**: Packaging web assets into a lightweight, secure container image based on `nginx:1.27-alpine`.
2. **Cluster Initialization**: Launching and managing a local Kubernetes cluster with `minikube` powered by the Docker driver.
3. **Declarative Deployments**: Authoring Kubernetes YAML specifications for `Deployment` and `Service` resources.
4. **Service Exposure**: Exposing applications to internal cluster traffic and external host traffic via `NodePort` services.
5. **Horizontal Scaling & Self-Healing**: Scaling Pod replicas to ensure high availability and verifying automatic rescheduling when pods are terminated.
6. **Health Checking**: Implementing `readinessProbe` and `livenessProbe` checks for zero-downtime rollouts.

---

## 🏗 Architecture & Key Concepts

```
                                  +-------------------------------------------------------------+
                                  |                 Minikube Cluster (Node)                     |
                                  |                                                             |
+--------------------------+      |    +-------------------------+    +--------------------+    |
|   Host Machine Browser   |      |    |       NodePort Service  |    |  ReplicaSet (x3)   |    |
|                          |=====>|===>|   Port: 80              |===>|                    |    |
|  http://localhost:8080   |      |    |   TargetPort: 80        |    |  +---------------+ |    |
|  http://localhost:8081   |      |    |   NodePort: 30000-32767 |    |  | Pod (Replica) | |    |
+--------------------------+      |    +-------------------------+    |  +---------------+ |    |
                                  |                                   |  | Pod (Replica) | |    |
                                  |                                   |  +---------------+ |    |
                                  |                                   |  | Pod (Replica) | |    |
                                  |                                   |  +---------------+ |    |
                                  |                                   +--------------------+    |
                                  +-------------------------------------------------------------+
```

### Core Kubernetes Primitives Used

- **Pod**: The basic execution unit in Kubernetes. Each pod encapsulates one or more application containers, storage resources, and a unique network IP.
- **Deployment**: Provides declarative updates for Pods and ReplicaSets. Describes the desired state (e.g., 3 replicas of an image); the Deployment controller continuously reconciles actual state to match.
- **ReplicaSet**: Ensures that a specified number of pod replicas are running at any given time.
- **Service (NodePort)**: An abstraction that defines a logical set of Pods and a policy to access them. `NodePort` allocates a high-range static port (`30000-32767`) on every node, routing external requests to the matching Pods.
- **Probes**:
  - `readinessProbe`: Validates that the application is ready to accept incoming user traffic before marking the Pod as `Ready`.
  - `livenessProbe`: Periodically checks if the container is healthy; if it fails, kubelet automatically restarts the container.

---

## 📁 Project Directory Structure

```text
kubernetes-minikube-Demo/
├── .dockerignore                 # Excludes documentation, git, and scripts from Docker image build
├── .gitignore                    # Git ignore file for OS artifacts, caches, and logs
├── Dockerfile                    # Multi-stage/alpine Nginx build definition for the project website
├── README.md                     # Comprehensive technical documentation & runbook
├── app.js                        # Frontend interactive script (collapsible panels, tabs, copy helpers)
├── index.html                    # Responsive academic project dashboard & lab reference UI
├── styles.css                    # Modern dark-mode styling with blue glow accents and responsive layout
│
├── k8s/                          # Kubernetes Declarative Manifests
│   ├── original-deployment.yaml  # Deployment spec for standard nginx:latest lab demo (3 replicas)
│   ├── original-service.yaml     # NodePort Service exposing port 80 for nginx-demo
│   ├── site-deployment.yaml      # Deployment spec for containerized project website (3 replicas)
│   └── site-service.yaml         # NodePort Service exposing port 80 for kubernetes-project-site
│
└── scripts/                      # Automation & Helper Scripts (PowerShell)
    ├── cleanup.ps1               # Deletes all deployed deployments and services
    ├── deploy-original.ps1       # Automates Minikube start and deploys original Nginx lab
    └── deploy-site.ps1           # Automates image build, Minikube image load, and deployment
```

---

## ⚙️ Prerequisites & System Setup

Ensure the following tools are installed on your Windows machine:

1. **Windows 10/11 with PowerShell**
2. **Docker Desktop** (with the WSL 2 backend enabled and running)
3. **Minikube** (`v1.30+`)
4. **kubectl** (`v1.28+`)

### Automatic Tool Installation (PowerShell with winget)

```powershell
winget install Kubernetes.minikube
winget install Kubernetes.kubectl
winget install Docker.DockerDesktop
```

Verify your CLI installations:

```powershell
docker --version
minikube version
kubectl version --client
```

---

## 🚀 Quick Start Guide

### Step 1: Start Docker Desktop & Launch Minikube

Ensure Docker Desktop is open and the Linux engine is active. Then start Minikube:

```powershell
minikube start --driver=docker
```

Confirm that the Minikube node is in the `Ready` state:

```powershell
kubectl get nodes
```

---

## 📦 Deployment Option A: Original Nginx Lab

This path reproduces the standard **Program 12** academic lab: deploying the official `nginx` image, exposing port 80 through a NodePort service, and scaling to 3 replicas.

### 1. Declarative Deployment (Recommended)

Run the included automated script:

```powershell
.\scripts\deploy-original.ps1
```

Or apply the manifests manually using `kubectl`:

```powershell
# 1. Apply Deployment and Service manifests
kubectl apply -f .\k8s\original-deployment.yaml
kubectl apply -f .\k8s\original-service.yaml

# 2. Wait for the rollout to complete
kubectl rollout status deployment/nginx-demo

# 3. Verify running Pods and Services
kubectl get pods -l app=nginx-demo
kubectl get services nginx-demo
```

### 2. Imperative Command Sequence

If you prefer to execute the commands interactively step-by-step:

```powershell
# Create the Deployment
kubectl create deployment nginx-demo --image=nginx

# Expose as a NodePort Service
kubectl expose deployment nginx-demo --type=NodePort --port=80

# Scale to 3 replicas
kubectl scale deployment nginx-demo --replicas=3
```

### 3. Accessing the Application

On Windows with the Docker driver, open the tunnel URL directly:

```powershell
minikube service nginx-demo --url
```

Or port-forward to a fixed local port:

```powershell
kubectl port-forward svc/nginx-demo 8080:80
```
Then navigate to `http://localhost:8080` in your browser.

---

## 🌐 Deployment Option B: Custom Containerized Project Website

This option builds this repository's presentation website into an Nginx Alpine container, loads the image into Minikube's local registry, and deploys it with 3 replicas.

### 1. Build and Load the Image

```powershell
# Build the local Docker image
docker build -t kubernetes-project-site:1.0 .

# Transfer the image directly into Minikube's internal container cache
minikube image load kubernetes-project-site:1.0
```

### 2. Deploy Manifests

Run the deployment script:

```powershell
.\scripts\deploy-site.ps1
```

Or apply manually:

```powershell
kubectl apply -f .\k8s\site-deployment.yaml
kubectl apply -f .\k8s\site-service.yaml
kubectl rollout status deployment/kubernetes-project-site
```

### 3. Access the Project Site

Forward the service port:

```powershell
kubectl port-forward svc/kubernetes-project-site 8081:80
```
Open your browser at `http://localhost:8081`.

---

## 💻 Deployment Option C: Standalone Local Preview

To view and edit the project presentation website directly on your host machine without running Docker or Kubernetes:

```powershell
# Using Python built-in HTTP server:
py -m http.server 8000
```
Visit `http://localhost:8000`.

---

## 🔌 Cluster Networking & Windows Port-Forwarding

Because Minikube on Windows with the Docker driver runs inside a WSL 2 VM container, NodePort IP addresses (`192.168.49.2:3xxxx`) are not directly reachable from the Windows host network stack without tunneling or port forwarding.

### Recommended Access Methods

| Method | Command | Why / When to use |
| :--- | :--- | :--- |
| **kubectl Port-Forward** *(Recommended)* | `kubectl port-forward svc/<svc-name> <port>:80` | Clean, stable localhost URLs (`localhost:8080`), survives node IP changes. |
| **minikube service** | `minikube service <svc-name> --url` | Automatically opens a background tunnel and prints a dynamic `127.0.0.1:XXXXX` URL. |
| **minikube tunnel** | `minikube tunnel` | Creates a network route for `LoadBalancer` services. Requires admin privileges. |

---

## 🔍 Verification & Observability Commands

Use these commands to inspect and diagnose your Kubernetes cluster:

```powershell
# List all pods with IP addresses and host node
kubectl get pods -o wide

# Monitor deployment rollout progress
kubectl rollout status deployment/nginx-demo
kubectl rollout status deployment/kubernetes-project-site

# Detailed status and lifecycle events of a Pod
kubectl describe pod <pod-name>

# View container output logs
kubectl logs -f <pod-name>

# Inspect all services and allocated NodePorts
kubectl get services

# View cluster resource consumption
kubectl top nodes
kubectl top pods
```

---

## 🛠 Troubleshooting & FAQs

### 1. `docker` or `minikube` command is not recognized
- Ensure `C:\Program Files\Docker\Docker\resources\bin` and Minikube's installation directory are present in your Windows `PATH` environment variable.
- Restart your PowerShell terminal session.

### 2. Docker daemon connection error (`npipe:////./pipe/dockerDesktopLinuxEngine`)
- Start the Docker Desktop application from the Windows Start menu.
- Verify that Docker Desktop has fully booted:
  ```powershell
  docker ps
  ```

### 3. Pod is stuck in `ImagePullBackOff` or `ErrImageNeverPresent`
- When using custom local images with Minikube, Kubernetes looks for the image inside the Minikube VM, not on the host.
- Always run:
  ```powershell
  minikube image load kubernetes-project-site:1.0
  ```
- Verify the image exists inside the cluster:
  ```powershell
  minikube image ls | Select-String "kubernetes-project-site"
  ```

### 4. Pod stays in `ContainerCreating`
- Check events by describing the Pod:
  ```powershell
  kubectl describe pod <pod-name>
  ```
- Ensure Minikube has sufficient RAM and CPU allocated (recommended: minimum 2 CPUs, 4GB RAM).

---

## 🧹 Resource Teardown & Cleanup

To remove all deployed Kubernetes resources without deleting the cluster:

```powershell
.\scripts\cleanup.ps1
```

Or delete them manually:

```powershell
kubectl delete deployment nginx-demo kubernetes-project-site
kubectl delete service nginx-demo kubernetes-project-site
```

To stop the Minikube cluster VM:

```powershell
minikube stop
```

To completely delete the Minikube cluster and free disk space:

```powershell
minikube delete
```

---

## 🐙 GitHub Repository Setup

To initialize and push this complete project to GitHub:

```powershell
# 1. Initialize git repository
git init

# 2. Stage all project files
git add .

# 3. Create initial commit
git commit -m "feat: complete kubernetes minikube demo project"

# 4. Rename main branch
git branch -M main

# 5. Add GitHub remote
git remote add origin https://github.com/abhinav307/kubernetes-minikube-Demo.git

# 6. Push to GitHub
git push -u origin main
```

---

## 📜 License & Acknowledgments

- Built for **Program 12** practical demonstration of Kubernetes container orchestration.
- Powered by [Minikube](https://minikube.sigs.k8s.io/) and [Kubernetes](https://kubernetes.io/).
- Nginx image provided by the official [Docker Hub Nginx Repository](https://hub.docker.com/_/nginx).
