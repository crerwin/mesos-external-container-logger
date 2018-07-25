# set up elastic

1. Install package
```
dcos package install elastic
```
2. check deploy progress
```
dcos elastic plan show deploy
```

# set up kibana
1. install package
```
dcos package install kibana
```
2. once deploy is complete, confirm that you see no elastic errors in the web interface

# install filebeat on all nodes
1. configure `~/.ssh/config` with IPs from cluster
2. cd to `./ansible` and run `ansible-playbook -i ./hosts filebeat.yml`

# configure kibana
1. set default index to `filebeat-*`

# Run a service and watch the containers fail
