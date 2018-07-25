# mesos-external-container-logger

This is a container logger module for [Mesos](http://mesos.apache.org/)
that redirects container logs to an external process.

It is a port to Mesos 1.4.0 of the `ExternalContainerLogger` module
developed in
[MESOS-6003](https://issues.apache.org/jira/browse/MESOS-6003).
Read the [documentation](https://reviews.apache.org/r/51258/) or this
[blog post](https://wjoel.com/posts/mesos-container-log-forwarding-with-filebeat.html)
for more information and some example use cases.

The module has been compiled for Debian 8 (jessie) and Debian testing (buster).
Use the `compile.sh` and optionally the
`build-mesos.sh` scripts to build the module for other distributions.
CMake 3.0.0 or later is required to build.

# Using on DC/OS

## Compile plugin
Compile Mesos and the plugin on your node OS, and copy the resulting compiled plugin to `ansible/files`.

## Test on Cluster

### set up elastic

1. Install package
```
dcos package install elastic
```
2. check deploy progress
```
dcos elastic plan show deploy
```

### set up kibana

1. install package
```
dcos package install kibana
```
2. once deploy is complete, confirm that you see no elastic errors in the web interface

### install filebeat on all nodes

1. configure `~/.ssh/config` with IPs from cluster
2. cd to `./ansible` and run `ansible-playbook -i ./hosts filebeat.yml`

### configure kibana

1. set default index to `filebeat-*`

### Run a service and watch the containers fail
