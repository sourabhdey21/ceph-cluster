#!/bin/bash 

## Note this pools are created for openstack intergration

ceph osd pool create volumes 32
ceph auth get-or-create client.cinder mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rx pool=images' -o /etc/ceph/ceph.client.cinder.keyring
ceph osd pool create vms 32
ceph auth get-or-create client.nova mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=vms, allow rx pool=images' -o /etc/ceph/ceph.client.nova.keyring
ceph osd pool create images
ceph osd pool set images  min_size 1
ceph osd pool set images  size 1
ceph auth get-or-create client.glance mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=images' -o /etc/ceph/ceph.client.glance.keyring
