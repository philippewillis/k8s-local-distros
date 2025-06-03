.PHONY: k8s-apply k8s-delete \
	minikube-start minikube-stop minikube-delete minikube-status minikube-dashboard minikube-ip \ 
	kind-single-node kind-single-delete use-kind-single-node kind-multi-node kind-multi-delete use-kind-multi-node kind-dashboard kind-ip kind-logs kind-status kind-use-ingress \ 
	k3d-cluster-create k3d-cluster-delete k3d-cluster-status k3d-dashboard \
	helm-charts helm-delete \
	docker-build docker-run

# KUBERNETES COMMANDS
k8s-apply:	
	@echo "Applying Kubernetes configurations..."
	kubectl apply -f k8s/hello-k8s/
	@echo "Kubernetes configurations applied successfully."
k8s-delete:
	@echo "Deleting Kubernetes configurations..."
	kubectl delete -f k8s/hello-k8s/
	@echo "Kubernetes configurations deleted successfully."



# k8s local-distro -> MINIKUBE COMMANDS
minikube-start:
	@echo "Starting Minikube..."
	minikube start
	@echo "Minikube started successfully."
minikube-stop:
	@echo "Stopping Minikube..."
	minikube stop
	@echo "Minikube stopped successfully."
minikube-delete:
	@echo "Deleting Minikube..."
	minikube delete
	@echo "Minikube deleted successfully."
minikube-status:
	@echo "Checking Minikube status..."
	minikube status
	@echo "Minikube status checked successfully."
minikube-dashboard:
	@echo "Opening Minikube dashboard..."
	minikube dashboard
	@echo "Minikube dashboard opened successfully."
minikube-ip:
	@echo "Getting Minikube IP..."
	minikube ip
	@echo "Minikube IP retrieved successfully."	



# k8s local-distro -> KIND COMMANDS
kind-single-node:
	@echo "Creating Kind single node cluster..."
	kind create cluster --name single-node --config kind/config-single-node.yml
	@echo "Kind single node cluster created successfully."
	kubectl cluster-info --context kind-single-node
kind-single-delete:
	@echo "Deleting Kind single node cluster..."
	kind delete cluster --name single-node
	@echo "Kind single node cluster deleted successfully."
use-kind-single-node:
	@echo "Creating Kind single node cluster..."
	@kubectl config use-context kind-single-node
kind-multi-node:
	@echo "Creating Kind multi node cluster..."
	kind create cluster --name multi-node --config kind/config-multi-node.yml
	@echo "Kind multi node cluster created successfully."
kind-multi-delete:
	@echo "Deleting Kind multi node cluster..."
	kind delete cluster --name multi-node
	@echo "Kind multi node cluster deleted successfully."
use-kind-multi-node:
	@echo "Creating Kind multi node cluster..."
	@kubectl config use-context kind-multi-node

kind-dashboard:
	@echo "Deploying Kubernetes Dashboard..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
	@echo "Creating admin-user and clusterrolebinding..."
	kubectl create serviceaccount admin-user -n kubernetes-dashboard --dry-run=client -o yaml | kubectl apply -f -
	kubectl create clusterrolebinding admin-user-binding \
	  --clusterrole=cluster-admin \
	  --serviceaccount=kubernetes-dashboard:admin-user \
	  --dry-run=client -o yaml | kubectl apply -f -
	@echo "Port forwarding dashboard to https://localhost:8443 (CTRL+C to stop)..."
	@echo "Use the following token to log in:"
	kubectl -n kubernetes-dashboard create token admin-user
	kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard 8443:443
	@echo "Kubernetes Dashboard deployed successfully. Access it at: https://localhost:8443"
kind-ip:
	@echo "Getting Kind single node cluster IP..."
	@kind get clusters | grep single-node || echo "No single node cluster found."
	@echo "Kind single node cluster IP retrieved successfully (if applicable)."
kind-logs:
	@echo "Getting logs for Kind single node cluster..."
	kind export logs --name single-node
	@echo "Logs for Kind single node cluster retrieved successfully."
kind-status:
	@echo "Checking Kind single node cluster status..."
	kind get clusters
	@echo "Kind single node cluster status checked successfully."
kind-use-ingress:
	@echo "Using Kind single node cluster ingress..."
	kubectl apply --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/heads/main/deploy/static/provider/kind/deploy.yaml



# k8s local-distro -> K3D COMMANDS
k3d-cluster-create:
	@echo "Creating K3D cluster..."
	k3d cluster create --config k3d/config-k3d.yml
	@echo "K3D cluster created successfully."
k3d-cluster-delete:
	@echo "Deleting K3D cluster..."
	k3d cluster delete my-k3d-cluster
	@echo "K3D cluster deleted successfully."
k3d-cluster-status:
	@echo "Checking K3D cluster status..."
	k3d cluster list
	@echo "K3D cluster status checked successfully."
k3d-use-ingress:
	@echo "Installing Traefik ingress for K3D..."
	@echo "Traefik is already installed with k3d, checking status..."
	kubectl wait --namespace kube-system --for=condition=ready pod --selector=app.kubernetes.io/name=traefik --timeout=90s
	@echo "Traefik ingress controller is ready."
k3d-dashboard:
	@echo "Installing Kubernetes Dashboard..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
	@echo "Waiting for dashboard deployment..."
	kubectl wait --for=condition=available --timeout=300s deployment/kubernetes-dashboard -n kubernetes-dashboard
	@echo "Creating admin user..."
	kubectl apply -f k3d/dashboard-admin.yml
	@echo "Getting access token..."
	@echo "Dashboard will be available at: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
	@echo "Use this token to login:"
	@kubectl -n kubernetes-dashboard create token admin-user
	@echo "Starting kubectl proxy (press Ctrl+C to stop)..."
	kubectl proxy


# Helm Charts
helm-charts:
	@echo "Installing Helm Charts..."
	@helm install simple-app ./charts/simple-app
	@echo "Application should be available at: http://localhost"
helm-delete:
	@echo "Uninstalling Helm Charts..."
	@helm uninstall simple-app --ignore-not-found
	@echo "Helm Charts uninstalled successfully."



# DOCKER COMMANDS
docker-build: docker-load-to-k3d
	@echo "Building Docker image..."
	@docker build -t hello-k8s:0.0.1 docker/.
	@docker images | grep hello-k8s
	@echo "Docker image built successfully."	
docker-run:
	@echo "Running Docker container (hello-k8s:0.0.1) at http://localhost:8081 ..."
	@docker run --rm -p 8081:80 --name hello-k8s hello-k8s:0.0.1
docker-load-to-k3d:
	@echo "Loading Docker image into K3D cluster..."
	@k3d image import hello-k8s:0.0.1 --cluster my-k3d-cluster
	@echo "Docker image loaded into K3D cluster successfully."