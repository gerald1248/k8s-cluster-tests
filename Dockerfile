FROM ubuntu:18.04
LABEL maintainer="Gerald Schmidt <gerald1248@gmail.com>"
LABEL description="Automated tests for Kubernetes clusters"
ENV KUBE_VERSION=v1.12.0
ENV SHUNIT_COLOR=none
RUN apt-get update && apt-get install -y jq apt-transport-https wget curl gnupg
RUN wget -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl && \
  chmod +x /usr/local/bin/kubectl
RUN groupadd app && useradd -g app app && \
  mkdir /app && \
  mkdir /etc/k8s-cluster-tests.d && \
  chmod 777 /app && \
  chown app:app /etc/k8s-cluster-tests.d
RUN wget -O /usr/bin/shunit2 https://raw.githubusercontent.com/kward/shunit2/master/shunit2
ADD test/*_test /etc/k8s-cluster-tests.d/
ADD bin/k8s-cluster-tests /usr/bin/
RUN chmod +x /usr/bin/k8s-cluster-tests
WORKDIR /app
USER app
CMD ["/bin/sh", "-c", "while true; do sleep 60; done"]
