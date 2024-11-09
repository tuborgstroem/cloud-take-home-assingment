#!/usr/bin/env bash

export CLUSTER_NAME=drdk-cloud-assignment

help() {
  echo "
  Usage: setup.sh [command]

  Commands:
    bootstrap  Create a local kind cluster, build the Docker image, load the image into the cluster, and deploy the contents of /k8s.
"
  exit 1
}

requirements() {
  command -v kind > /dev/null  || (echo "kind is not installed. Please install kind" && exit 1)
  command -v docker > /dev/null || (echo "docker is not installed. Please install docker" && exit 1)
  command -v kubectl > /dev/null  || (echo "kubectl is not installed. Please install kubectl" && exit 1)
}

create_cluster() {
  if kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo "The Kind cluster $CLUSTER_NAME already exists."
  else
    kind create cluster --name "$CLUSTER_NAME"
  fi
}

set_kubectx() {
  kubectl config use-context "kind-$CLUSTER_NAME"
}

build_image() {
  echo "Building the docker image..."
  docker build -q -t cat-app:v1 .
}

load_image() {
  echo "Loading the docker image into the cluster..."
  kind load docker-image --name "$CLUSTER_NAME" cat-app:v1
}

deploy_app() {
  echo "Deploying the application..."
  kubectl apply -f k8s/deployment.yaml --context "kind-$CLUSTER_NAME"
}

case "$1" in
  bootstrap)
    requirements
    create_cluster
    set_kubectx
    build_image
    load_image
    deploy_app
    ;;
  *)
    help
    ;;
esac
