#!/bin/bash

set -e
gcloud config set project $GCLOUD_PROJECT
gcloud compute project-info add-metadata --metadata-from-file sshKeys=$SSH_PUB_KEY

#create docker disks
gcloud compute disks create "infranode1-docker" --size "200" --zone "us-central1-a" --type "pd-standard" &
gcloud compute disks create "infranode2-docker" --size "200" --zone "us-central1-c" --type "pd-standard" &
gcloud compute disks create "node1-docker" --size "200" --zone "us-central1-c" --type "pd-standard" &
gcloud compute disks create "node2-docker" --size "200" --zone "us-central1-c" --type "pd-standard" &
gcloud compute disks create "node3-docker" --size "200" --zone "us-central1-c" --type "pd-standard" &
wait

#Masters
gcloud compute instances create "master1" --zone "us-central1-a" --machine-type "n1-standard-4" --subnet "default" --maintenance-policy "MIGRATE" --scopes default="https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly" --image "/rhel-cloud/rhel-7-v20160921" --boot-disk-size "20" --boot-disk-type "pd-standard" --boot-disk-device-name "master1" &
gcloud compute instances create "master2" --zone "us-central1-b" --machine-type "n1-standard-4" --subnet "default" --maintenance-policy "MIGRATE" --scopes default="https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly" --image "/rhel-cloud/rhel-7-v20160921" --boot-disk-size "20" --boot-disk-type "pd-standard" --boot-disk-device-name "master2" &
gcloud compute instances create "master3" --zone "us-central1-c" --machine-type "n1-standard-4" --subnet "default" --maintenance-policy "MIGRATE" --scopes default="https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly" --image "/rhel-cloud/rhel-7-v20160921" --boot-disk-size "20" --boot-disk-type "pd-standard" --boot-disk-device-name "master3" &

#infranodes
gcloud compute instances create "infranode1" --zone "us-central1-a" --machine-type "n1-highmem-4" --subnet "default" --maintenance-policy "MIGRATE" --scopes default="https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly" --disk "name=infranode1-docker,device-name=disk-1,mode=rw,boot=no" --image "/rhel-cloud/rhel-7-v20160921" --boot-disk-size "20" --boot-disk-type "pd-standard" --boot-disk-device-name "infranode1" &
gcloud compute instances create "infranode2" --zone "us-central1-c" --machine-type "n1-highmem-4" --subnet "default" --maintenance-policy "MIGRATE" --scopes default="https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly" --disk "name=infranode2-docker,device-name=disk-1,mode=rw,boot=no" --image "/rhel-cloud/rhel-7-v20160921" --boot-disk-size "20" --boot-disk-type "pd-standard" --boot-disk-device-name "infranode2" &

#nodes
gcloud compute instances create "node1" --zone "us-central1-c" --machine-type "n1-highmem-4" --subnet "default" --maintenance-policy "MIGRATE" --scopes default="https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly" --disk "name=node1-docker,device-name=disk-1,mode=rw,boot=no" --image "/rhel-cloud/rhel-7-v20160921" --boot-disk-size "20" --boot-disk-type "pd-standard" --boot-disk-device-name "node1" &
gcloud compute instances create "node2" --zone "us-central1-c" --machine-type "n1-highmem-4" --subnet "default" --maintenance-policy "MIGRATE" --scopes default="https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly" --disk "name=node2-docker,device-name=disk-1,mode=rw,boot=no" --image "/rhel-cloud/rhel-7-v20160921" --boot-disk-size "20" --boot-disk-type "pd-standard" --boot-disk-device-name "node2" &
gcloud compute instances create "node3" --zone "us-central1-c" --machine-type "n1-highmem-4" --subnet "default" --maintenance-policy "MIGRATE" --scopes default="https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly" --disk "name=node3-docker,device-name=disk-1,mode=rw,boot=no" --image "/rhel-cloud/rhel-7-v20160921" --boot-disk-size "20" --boot-disk-type "pd-standard" --boot-disk-device-name "node3" &
wait

# create static addresses
gcloud compute addresses create "master-external" --region "us-central1" &
gcloud compute addresses create "infranode-external" --region "us-central1" &
gcloud compute addresses create "ose-bastion" --region "us-central1" &
wait

# create target pools
gcloud compute target-pools create master-pool --region us-central1 &
gcloud compute target-pools create infranode-pool --region us-central1 &
wait
gcloud compute target-pools add-instances master-pool --instances master1 --zone us-central1-a &
gcloud compute target-pools add-instances master-pool --instances master2 --zone us-central1-b &
gcloud compute target-pools add-instances master-pool --instances master3 --zone us-central1-c &
gcloud compute target-pools add-instances infranode-pool --instances infranode1 --zone us-central1-a &
gcloud compute target-pools add-instances infranode-pool --instances infranode2 --zone us-central1-c &
wait

#create instance groups
gcloud compute instance-groups unmanaged create master1 --zone us-central1-a &
gcloud compute instance-groups unmanaged create master2 --zone us-central1-b &
gcloud compute instance-groups unmanaged create master3 --zone us-central1-c &
wait

gcloud compute instance-groups unmanaged add-instances master1 --instances master1 --zone us-central1-a &
gcloud compute instance-groups unmanaged add-instances master2 --instances master2 --zone us-central1-b &
gcloud compute instance-groups unmanaged add-instances master3 --instances master3 --zone us-central1-c &
wait

#create back-end service
gcloud beta compute health-checks create tcp master-health-check --port 80
gcloud beta compute backend-services create master-internal --load-balancing-scheme internal --region us-central1 --protocol tcp --port 8443 --health-checks master-health-check

gcloud beta compute backend-services add-backend master-internal --instance-group master1 --instance-group-zone us-central1-a --region us-central1 
gcloud beta compute backend-services add-backend master-internal --instance-group master2 --instance-group-zone us-central1-b --region us-central1 
gcloud beta compute backend-services add-backend master-internal --instance-group master3 --instance-group-zone us-central1-c --region us-central1 


#create load balancers
gcloud compute forwarding-rules create master-external --region us-central1 --ports 8443 --address `gcloud compute addresses list | grep master-external | awk '{print $3}'` --target-pool master-pool &
gcloud compute forwarding-rules create infranode-external-443 --region us-central1 --ports 443 --address `gcloud compute addresses list | grep infranode-internal | awk '{print $3}'` --target-pool infranode-pool &
gcloud compute forwarding-rules create infranode-external-80 --region us-central1 --ports 80 --address `gcloud compute addresses list | grep infranode-external | awk '{print $3}'`  --target-pool infranode-pool &
gcloud beta compute forwarding-rules create master-internal --load-balancing-scheme internal --ports 8443 --region us-central1 --backend-service master-internal &
wait

#ose-bastion
gcloud compute instances create "ose-bastion" --zone "us-central1-a" --machine-type "n1-standard-2" --subnet "default" --maintenance-policy "MIGRATE" --scopes default="https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly" --image "/rhel-cloud/rhel-7-v20160921" --boot-disk-size "20" --boot-disk-type "pd-standard" --boot-disk-device-name "ose-bastion" --address `gcloud compute addresses list | grep ose-bastion | awk '{print $3}'`
