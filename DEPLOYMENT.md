# Deployment Guide for Login Web Application on Kubernetes

This guide provides step-by-step instructions for deploying the login web application with MySQL database on Kubernetes. All configuration files are already included in the repository.

## 1. Clean Up Previous Deployments

First, clean up any previous deployments related to this project:

```bash
# Delete deployments
kubectl delete deployment login-app mysql

# Delete services
kubectl delete service login-app mysql

# Delete PVCs and PVs
kubectl delete pvc mysql-pvc
kubectl delete pv mysql-pv

# Delete secrets
kubectl delete secret mysql-secret
```
## 2. Build and Load Docker Image

Navigate to the app directory and build the Docker image:

```bash
# Navigate to app directory
cd k8s-login-app/app

# Build Docker image
docker build -t login-app:latest .

# Save Docker image as TAR file for distribution to worker nodes
docker save login-app:latest > login-app.tar
```

If your worker nodes don't share the Docker registry with your control plane, transfer and load the image on all nodes:

```bash
# Transfer the image to worker nodes (replace with actual node IPs)
scp login-app.tar user@worker-node:/home/user/

# On each worker node, load the image
docker load < login-app.tar
```

## 3. Prepare Storage for MySQL

Create a directory on your worker node to store MySQL data:

```bash
# Create a directory on your worker node for MySQL data (execute on worker node)
sudo mkdir -p /mnt/data
sudo chmod 777 /mnt/data
```

## 4. Deploy MySQL Database

Apply the MySQL configurations:

```bash
# Apply MySQL configurations
kubectl apply -f k8s/mysql-secret.yaml
kubectl apply -f k8s/mysql-pv.yaml
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/mysql-service.yaml
kubectl apply -f k8s/mysql-deployment.yaml

# Check if MySQL pod is running
kubectl get pods -l app=mysql

# Wait for MySQL pod to be ready
kubectl wait --for=condition=ready pod -l app=mysql --timeout=180s
```

## 5. Deploy Web Application

Deploy the web application after MySQL is running:

```bash
# Apply web application configurations
kubectl apply -f k8s/web-deployment.yaml
kubectl apply -f k8s/web-service.yaml

# Check if web application pods are running
kubectl get pods -l app=login-app
```

## 6. Access the Application

The application is exposed through a NodePort service on port 30080:

```
http://10.34.7.115:30080
```

Replace `10.34.7.115` with your Kubernetes node IP address.

## 7. Testing the Application

1. Open your web browser and navigate to `http://10.34.7.115:30080`
2. Register a new user or use the default credentials:
   - Username: `admin`
   - Password: `admin123`
3. After login, you'll be redirected to the dashboard where you can upload images

## 8. Troubleshooting

If you encounter issues:

```bash
# Check pod status
kubectl get pods

# Check MySQL logs
kubectl logs -l app=mysql

# Check web application logs
kubectl logs -l app=login-app

# Check MySQL connectivity from web app
kubectl exec -it $(kubectl get pod -l app=login-app -o jsonpath='{.items[0].metadata.name}') -- sh -c 'nc -zv mysql 3306'

# Check service configuration
kubectl get svc
```

## 9. Database Management

To manually manage the database:

```bash
# Connect to MySQL
kubectl exec -it $(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- mysql -u root -p

# Enter password: Otomasi-13

# Then run MySQL commands
USE loginapp;
SHOW TABLES;
SELECT * FROM users;
```

This completes the deployment of the login web application with MySQL on Kubernetes.
```