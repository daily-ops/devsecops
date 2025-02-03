#!/bin/bash

source ./up.env

export VAGRANT_HOME=/var/data/vagrant

vagrant destroy -f
