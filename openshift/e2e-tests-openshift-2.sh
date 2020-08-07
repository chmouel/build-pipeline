#!/usr/bin/env bash
set -e
source $(git rev-parse --show-toplevel)/openshift/e2e-common.sh

# Set by CI
OPENSHIFT_REGISTRY_PREFIX="${OPENSHIFT_REGISTRY_PREFIX:-${IMAGE_FORMAT//:\$\{component\}/}}"
OPENSHIFT_BUILD_NAMESPACE=${OPENSHIFT_BUILD_NAMESPACE:-tektoncd-build-$$}
OPENSHIFT_REGISTRY_TAG=${OPENSHIFT_REGISTRY_TAG:-""}

# The examples, we need to evaluate those again
TEST_EXAMPLES_IGNORES=".*(/(sidecar-ready-script|custom-volume|pipelinerun-using-different-subpaths-of-workspace|creds-init-only-mounts-provided-credentials|dind-sidecar|pipelinerun|run-steps-as-non-root|authenticating-git-commands|pull-private-image|build-push-kaniko|git-volume|cloud-event)\.yaml$|gcs.*)"

export OPENSHIFT_REGISTRY_PREFIX OPENSHIFT_BUILD_NAMESPACE TEST_EXAMPLES_IGNORES

# Script entry point.

header "Setting up environment"

# install_pipeline_crd

# Run the integration tests
failed=0

# Run the integration tests
header "Running Go e2e tests"
go_test_e2e -tags=e2e -timeout=20m ./test -skipRootUserTests=true || failed=1

header "Running Go examples test"
# Run these _after_ the integration tests b/c they don't quite work all the way
# and they cause a lot of noise in the logs, making it harder to debug integration
# test failures.
go_test_e2e -tags=examples -timeout=20m ./test/ || failed=1

(( failed )) && fail_test
success
