#!/usr/bin/env bash
set -eu

source $(git rev-parse --show-toplevel)/vendor/github.com/tektoncd/plumbing/scripts/e2e-tests.sh
source $(git rev-parse --show-toplevel)/resolve-yamls.sh

function install_pipeline_crd() {
  echo ">> Deploying Tekton Pipelines"

  generate_pipeline_resources /tmp/tekton-pipeline-resolved.yaml $OPENSHIFT_REGISTRY_PREFIX

  oc apply -f /tmp/tekton-pipeline-resolved.yaml

  verify_pipeline_installation
}

function uninstall_pipeline_crd() {
  echo ">> Uninstalling Tekton Pipelines"
  oc delete --ignore-not-found=true -f /tmp/tekton-pipeline-resolved.yaml

  # Make sure that everything is cleaned up in the current namespace.
  delete_pipeline_resources
}

function verify_pipeline_installation() {
  # chmou: upstream has this but my feeling is that it is buggy
  # Make sure that everything is cleaned up in the current namespace.
  # delete_pipeline_resources

  # Wait for pods to be running in the namespaces we are deploying to
  wait_until_pods_running tekton-pipelines || fail_test "Tekton Pipeline did not come up"
}

function delete_pipeline_resources() {
  for res in conditions pipelineresources tasks clustertasks pipelines taskruns pipelineruns; do
    kubectl delete --ignore-not-found=true ${res}.tekton.dev --all
  done
}
