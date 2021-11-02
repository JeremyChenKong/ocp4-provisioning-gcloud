#!/usr/bin/env bash
set -x -u -e
gcp_project_sa="${gcp_project}-sa"
gcp_project_domain="${gcp_project}-domain"

#create project and set project
gcloud projects create ${gcp_project}
gcloud config set project ${gcp_project}

#linking billing account:
gcloud alpha billing projects link ${gcp_project} --billing-account $(gcloud alpha billing accounts list | tail -1 | awk '{print $1}')

#enable apis
gcloud services enable compute.googleapis.com --project ${gcp_project}
gcloud services enable cloudapis.googleapis.com --project ${gcp_project}
gcloud services enable cloudresourcemanager.googleapis.com --project ${gcp_project}
gcloud services enable dns.googleapis.com --project ${gcp_project}
gcloud services enable iam.googleapis.com --project ${gcp_project}
gcloud services enable servicemanagement.googleapis.com --project ${gcp_project}
gcloud services enable serviceusage.googleapis.com --project ${gcp_project}
gcloud services enable storage-api.googleapis.com --project ${gcp_project}
gcloud services enable storage-component.googleapis.com --project ${gcp_project}
gcloud services enable cloudbilling.googleapis.com --project ${gcp_project}

#Create service account
gcloud iam service-accounts create "${gcp_project_sa}"

#Assign onwer
gcloud projects add-iam-policy-binding ${gcp_project} --member "serviceAccount:${gcp_project_sa}@${gcp_project}.iam.gserviceaccount.com" --role "roles/owner"

#Created public managed zone
gcloud dns managed-zones create ${gcp_project_domain} --dns-name "${dns_name:-${gcp_project}.io}" --description "${gcp_project_domain}"

#create .gcp dir
mkdir -p ~/.gcp

#Download gcp credential keys to the .gcp dir
gcloud iam service-accounts keys create ${HOME}/.gcp/osServiceAccount.json --iam-account ${gcp_project_sa}@${gcp_project}.iam.gserviceaccount.com

#create  openshift installtion artefacts dir
mkdir ocp4

#Create openshift cluster using openshift-install from redhat
openshift-install create cluster --dir=ocp4

