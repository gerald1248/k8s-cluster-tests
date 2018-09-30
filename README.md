# Kubernetes cluster tests

![Docker Automated](https://img.shields.io/docker/automated/gerald1248/cluster-tests.svg)
![Docker Build](https://img.shields.io/docker/build/gerald1248/cluster-tests.svg)

![Overview of cluster-tests](ditaa/chart.png)

Use `cluster-tests` to test those aspects of your Kubernetes cluster that are not already covered by monitoring and health checks. Run tests periodically with read-only access to all projects.

For example, you could assert that:

* non-admin users must not be given the role `self-provisioner`
* service account `default` must not have security context constraint `anyuid` (ideally the rule would apply to all service accounts) 
* pods in user projects must not run in privileged security context
* and so on

Admin access is required at the start (to create project and the `cluster-reader` ClusterRoleBinding for the service account), but from then on access is strictly controlled. Logging is handled via `stdout` as usual and easily filtered in Kibana (or similar) by focusing on the chosen namespace.

![Permissions](ditaa/permissions.png)

The default set of tests includes the following:
```
test
├── anyuid_test
├── exports
├── limits_test
├── nodes_test
├── privileged_test
└── self_provisioner_test
```

The `exports` file exports variables such as `USER_PROJECTS` and `NODES`, which can then be used and reused freely in tests.

The test pod has `oc`, `curl`, `jq`, `psql` and so on to examine the cluster from within, with `cluster-reader` access. It mounts the test scripts (stored in a ConfigMap) and runs each one in turn.

## Run the tests
```
$ make
project "cluster-tests" created
serviceaccount "cluster-tests" created
cronjob "cluster-tests" created
rolebinding "system:deployers" created
deploymentconfig "cluster-tests" created
clusterrolebinding "cluster-tests" created
limitrange "cluster-tests" created
resourcequota "cluster-tests" created
configmap "cluster-tests" created
$ oc get po
NAME                     READY     STATUS    RESTARTS   AGE
cluster-tests-1-bcp2d   1/1       Running   0          4m 
$ oc exec cluster-tests-1-bcp2d cluster-tests
test_project_quotas
test_nodes_ready
test_nodes_no_warnings
test_security_context_privileged
test_anyuid
test_self_provisioner

Ran 6 tests.

OK
```

## Writing your own tests
To add tests, populate the folder `test` with additional files (each containing one or more Bash functions and an instruction to add them to the test suite). To update the ConfigMap, run:
```
$ make update-configmap
```
This will refresh the configmap from the contents of the `test` folder.

## Cleanup
Call `make clean` to remove the project `cluster-tests` and the rolebinding that gives the serviceaccount `cluster-tests` read-only access to all projects.

## Building the image
Run `make build-docker-image` to create a bespoke test runner image. In many cases, the version of the `oc` client should be adjusted from `latest` to a version that matches your cluster.

Tag the image as desired and upload to Docker Hub or a private registry as appropriate.

## Test the test-runner
Run `make test` to run the tests for the `cluster-tests` executable in the `bin` folder.

## Note on versions
The default image on Docker Hub ships with the current stable build of the `oc` client. You may wish to adjust the version tag in the `docker-build.sh` script and create an image that matches your cluster exactly.

Kubernetes versions prior to 1.8 offer limited support for CronJob objects (the version attribute has `v2alpha1`). If a process fails, the v2 alpha CronJob will keep spawning containers until a container returns zero. The problem is exacerbated by the fact that the CronJob object in these Kubernetes builds does not recognise the cleanup properties reducing the number of `completed` or `error` pods kept.

To deal with this (and to give users time to catch up), the CronJob always returns zero.
