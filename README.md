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

# Purpose

This plugin allows us to extract some useful information from the Mesos executor.  We can tag outgoing log messages with this information.

# How it works

The plugin hooks into the Mesos slave process and gets information from the Mesos executor protobuf.  For each Mesos task, it starts a new sidecar process that is considered part of the Mesos task.  This sidecar executable is provided through a configuration file, and can either be a shell script or a binary.  It is important to note that if this second process fails, the entire Mesos task will fail (and Marathon will restart it elsewhere).

The sidecar process started by the plugin has 3 important environment variables.  These variables only exist in the sidecar process, not in the main Mesos task process:

|variable|description|
---|---
|MESOS_LOG_STREAM|STDOUT or STDERR|
|MESOS_LOG_SANDBOX_DIRECTORY|The Mesos task's sandbox directory|
|MESOS_LOG_EXECUTORINFO_JSON|json containing all the pertinent information that the plugin acquired from the executor protobuf|

Note that "MESOS_LOG_" is simply a prefix.

The blog post this is based on shows an example of writing out a Filebeat configuration with these additional fields, and then starting a new Filebeat process.  This is done for both STDOUT and STDERR.  This means that for every 1 process you are running in Mesos, you are starting 3 additional processes (the sidecar process and two Filebeat processes).  If anything kills the sidecar process (for instance Filebeat exiting) your Mesos task goes down.

# Using on DC/OS

## Compile plugin
Compile Mesos and the plugin on your node OS (set mesos version to 1.5.0 in both compile scripts), and copy the resulting compiled plugin to `ansible/files`.

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

# Two problems
Flag is `--container_logger` not `--container-logger` and json needs to be changed to external_logger_script for the flag
