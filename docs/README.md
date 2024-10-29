# Mifos Gazelle Deployment Guide

[![Mifos](https://img.shields.io/badge/Mifos-Gazelle-blue)](https://github.com/openMF/mifos-gazelle)

> Deployment utilities for Mifos/Fineract, Payment Hub EE, and Mojaloop vNext (as of October 2024)

## Table of Contents
- [Goal](#goal-of-mifos-gazelle)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment Options](#deployment-options)
- [Application Deployment Modes](#application-deployment-modes)
- [Cleanup](#cleanup)
- [Accessing Deployed Applications](#accessing-deployed-applications)
  - [Mojaloop vNext](#accessing-mojaloop-vnext)
  - [Payment Hub](#accessing-payment-hub)
  - [Fineract](#accessing-mifosx-fineract)
- [Running helm test] (#helm-test)
- [Development Status](#development-status)

## Goal of Mifos Gazelle
The overall aim of Mifos Gazelle is to provide a trivially simple installation and configuration mechanism for Mifos applications and the Mojaloop vNext financial transactions switch. The idea is to create a rapidly deployable , understandable and cheap integration to serve as a showcase and a laboratory environment to enable others to build further on these DPI projects. 

## Prerequisites

Before proceeding with the deployment, ensure your system meets the following requirements:

- Ubuntu 20.04 LTS operating system
- x86_64 architecture
- 32GB RAM minimum
- 30GB+ free space in home directory
- Non-root user with sudo privileges

## Quick Start
logged in as non-root user e.g. mifosu user 
```bash
# Navigate to home directory
cd $HOME

# Clone the repository (dev branch)
git clone --branch dev https://github.com/openMF/mifos-gazelle.git

# Enter the project directory
cd mifos-gazelle

# Deploy all components (MifosX, vNext, and PHEE)
sudo ./run.sh -u $USER -m deploy -d true -a all
```

## Deployment Options

| Option | Description | Values |
|--------|-------------|---------|
| `-h` | Display help message | - |
| `-u` | Non-root user for deployment | Current user (`$USER`) |
| `-m` | Execution mode | `deploy`, `cleanapps`, `cleanall` |
| `-d` | Verbose output | `true`, `false` |
| `-a` | Applications to deploy | `all`, `vnext`, `mifosx`, `phee` |
| `-f` | Number of Fineract instances* | Default: 1 |
| `-e` | Deployment environment* | `local`, `remote` |

> *Note: `-f` and `-e` options are not currently implemented

## Application Deployment Modes

Choose specific components to deploy using the `-a` flag:

```bash
# Deploy only Mojaloop vNext
sudo ./run.sh -u $USER -m deploy -a vnext

# Deploy only Fineract
sudo ./run.sh -u $USER -m deploy -a mifosx

# Deploy only Payment Hub
sudo ./run.sh -u $USER -m deploy -a phee
```

## Cleanup

Remove deployed components:

```bash
# Remove everything including Kubernetes server
sudo ./run.sh -u $USER -m cleanall

# Remove all applications from the kubernetes server  
sudo ./run.sh -u $USER -m cleanapps

# Remove specific components
sudo ./run.sh -u $USER -m cleanapps -a mifosx  # Remove MifosX
sudo ./run.sh -u $USER -m cleanapps -a phee    # Remove PaymentHub EE
sudo ./run.sh -u $USER -m cleanapps -a vnext   # Remove vNext switch
```

## Accessing Deployed Applications

### Accessing Mojaloop vNext

#### Host Configuration

Add the following entries to your hosts file on the laptop/desktop system where your web browser is running where <VM-IP> (without the angle brackets) is the IP of the server or VM where Mifos Gazelle has been deployed. 

```bash
# Linux/MacOS (/etc/hosts)
<VM-IP>  vnextadmin elasticsearch.local kibana.local mongoexpress.local \
         kafkaconsole.local fspiop.local bluebank.local greenbank.local mifos.local

# Windows (C:\Windows\System32\drivers\etc\hosts)
<VM-IP> vnextadmin.local
<VM-IP> elasticsearch.local
<VM-IP> kibana.local
<VM-IP> mongoexpress.local
<VM-IP> kafkaconsole.local
<VM-IP> fspiop.local
<VM-IP> bluebank.local
<VM-IP> greenbank.local
```

### Accessing Payment Hub

#### Host Configuration

```bash
# Linux/MacOS (/etc/hosts)
<VM-IP> ops.mifos.gazelle.test ops-bk.mifos.gazelle.test bulk-connector.mifos.gazelle.test

# Windows (C:\Windows\System32\drivers\etc\hosts)
<VM-IP> ops.mifos.gazelle.test
<VM-IP> ops-bk.mifos.gazelle.test
<VM-IP> bulk-connector.mifos.gazelle.test
```

### Accessing MifosX Fineract

#### Host Configuration

```bash
# Linux/MacOS (/etc/hosts)
<VM-IP> fineract.mifos.gazelle.test mifos.mifos.gazelle.test

# Windows (C:\Windows\System32\drivers\etc\hosts)
<VM-IP> mifos.mifos.gazelle.test
<VM-IP> fineract.mifos.gazelle.test
```

## Helm test
helm tests are currently configured in the config/ph_values.yaml file , look for integration_tests. To execute the helm tests run 
```bash
helm test phee 
```
then examine the logfiles using either k9s or 
```bash
kubectl logs -n paymenthub ph-ee-integration-test-gazelle
```
you can access the results by copying them from the pod to the /tmp directory of the server machine or VM using the script below.  This will place the results into a directory similar to mydir.SzSauX i.e. of the form /tmp/mydir.XXXXXX. You will need to copy this directory from the server/VM to your desktop/laptop to browse the results , look for ths subdirectory of tests/test/index.html as the top level for your browser. Note that the pod will time-out after 90 mins and you will need to remove the ph-ee-integration-test-gazelle pod before running helm test phee again. 
```bash
~/mifos-gazelle/src/utils/copy-report-from-pod.sh 
``` 

## Development Status
Please note that limitations here are entirely those of the Mifos Gazelle configuration, and should not at all be interpreted as issues with the maturity or functionality of the deployed components.  
- currently operations-web UI https://ops.mifos.gazelle.test can access batches and transfers and can create and send batches to bulk. It is not yet clear that the batches are correctly processed on the back end, this of course is being worked on. 
-  ph-ee-integration-test docker image on dockerhub uses the tag  v1.6.2-gazelle and corresponds to the v1.6.2-gazelle branch of the v1.6.2 integration-test repo.  The helm tests as deployed by Gazelle reports approx 90% pass rate. 
- PaymentHub EE v 1.13.0 is being provisioned by Mifos Gazelle and this is set in the config.sh script prior to deployment. This document defines all the sub chart releases that comprise the v1.13.0 release https://mifos.gitbook.io/docs/payment-hub-ee/release-notes/v1.13.0
- there is a lot of tidying up to do once this is better tested, e.g. debug statements to remove and lots of redundant env vars to remove as well as commented out code to remove. 
- it should be straightforward to integrate the kubernetes operator work into this simplified single node deployment


### Known Issues
- Single instance deployment currently supported
- Some cleanup needed (debug statements, redundant environment variables)
- Kubernetes operator integration pending

For more detailed information about testing and postman collections, refer to `POSTMAN_SETUP.md` in the repository.