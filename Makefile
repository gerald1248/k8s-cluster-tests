# check for prerequisites
EXECUTABLES = docker jq
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),"",$(error "$(exec) not in path")))

# fetch name and namespace
NAME = $(shell jq -r .name values.yaml)
NAMESPACE = $(shell jq -r .namespace values.yaml)

# targets
build:
	docker build -t $(NAME) .
update:
	kubectl delete configmap $(NAME) --ignore-not-found -n $(NAMESPACE)
	kubectl create configmap $(NAME) -n $(NAMESPACE) --from-file=test/
push:
	docker tag $(NAME) gerald1248/$(NAME):latest
	docker push gerald1248/$(NAME):latest
install:
	helm install --namespace=$(NAMESPACE) --name=$(NAME) .
delete:
	helm delete --purge $(NAME)
test:
	./Dockerfile_test
	cd bin; ./$(NAME)_test

.PHONY: test
