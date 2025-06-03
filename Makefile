.PHONY: k8s-apply k8s-delete 

# KUBERNETES COMMANDS
k8s-apply:	
	@echo "Applying Kubernetes configurations..."
	kubectl apply -f k8s/
	@echo "Kubernetes configurations applied successfully."
k8s-delete:
	@echo "Deleting Kubernetes configurations..."
	kubectl delete -f k8s/
	@echo "Kubernetes configurations deleted successfully."