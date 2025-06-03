.PHONY: k8s-apply k8s-delete \
	minikube-start minikube-stop minikube-delete minikube-status minikube-dashboard minikube-ip

# KUBERNETES COMMANDS
k8s-apply:	
	@echo "Applying Kubernetes configurations..."
	kubectl apply -f k8s/
	@echo "Kubernetes configurations applied successfully."
k8s-delete:
	@echo "Deleting Kubernetes configurations..."
	kubectl delete -f k8s/
	@echo "Kubernetes configurations deleted successfully."



# MINIKUBE COMMANDS
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
