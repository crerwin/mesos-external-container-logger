#!/bin/bash

set -e

MESOS_VERSION=1.4.1

cmake -DWITH_MESOS=$PWD/mesos-install -DMESOS_SRC_DIR=$PWD/mesos-${MESOS_VERSION} || cmake3 -DWITH_MESOS=$PWD/mesos-install -DMESOS_SRC_DIR=$PWD/mesos-${MESOS_VERSION}
make -j 6 V=0
