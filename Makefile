ifeq (, $(shell which jq))
 $(error "Dependency jq not in $(PATH)")
endif

NAME = $(shell jq -r .name values.yaml)
NAMESPACE = $(shell jq -r .namespace values.yaml)

build:
	docker build -t $(NAME) .
push:
	docker tag $(NAME) gerald1248/$(NAME):latest
	docker push gerald1248/$(NAME):latest
install:
	helm install --name=$(NAME) .
	sleep 2
	kubectl delete configmap $(NAME) -n $(NAMESPACE)
	sleep 2
	kubectl create configmap $(NAME) -n $(NAMESPACE) --from-file=test/
delete:
	helm delete --purge $(NAME)
test:
	./Dockerfile_test
	cd bin; ./$(NAME)_test

.PHONY: test
