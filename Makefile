build:
	docker build -t k8s-cluster-tests .
push:
	docker tag k8s-cluster-tests gerald1248/k8s-cluster-tests:latest
	docker push gerald1248/k8s-cluster-tests:latest
install:
	helm install --name=k8s-cluster-tests .
	sleep 2
	kubectl delete configmap cluster-tests
	sleep 2
	kubectl create configmap cluster-tests -n default --from-file=test/
delete:
	helm delete --purge k8s-cluster-tests
