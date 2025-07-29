# Mifos Gazelle Deployment Guide
(a.k.a Gazelle)

[![Mifos](https://img.shields.io/badge/Mifos-Gazelle-blue)](https://github.com/openMF/mifos-gazelle)

> Mifos Digital Public Infrastructure as a Solution (DaaS) deployment tool v1.0.0 - July 2025.
Currently for deploying MifosX, PaymentHub EE and Mojaloop vNext Beta1 on Kubernetes

## Table of Contents
- [Mifos Gazelle Deployment Guide](#mifos-gazelle-deployment-guide)
  - [Table of Contents](#table-of-contents)
  - [Goal of Mifos Gazelle](#goal-of-mifos-gazelle)
  - [Gazelle features (benefits)](#gazelle-features-benefits)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
  - [Deployment Options](#deployment-options)
  - [What to do next](#what-to-do-next)
  - [Execute a transfer from Greenbank to Bluebank (New in v1.1.0)](#execute-a-transfer-from-greenbank-to-bluebank-new-in-v110)
  - [Application Deployment Modes](#application-deployment-modes)
  - [Cleanup](#cleanup)
  - [Accessing Deployed Applications (DPGs)](#accessing-deployed-applications-dpgs)
    - [vNext host Configuration](#vnext-host-configuration)
    - [Payment Hub EE host Configuration](#payment-hub-ee-host-configuration)
    - [Accessing MifosX](#accessing-mifosx)
      - [Host Configuration](#host-configuration)
  - [Helm test](#helm-test)
  - [More detail on adding tenants to MifosX](#more-detail-on-adding-tenants-to-mifosx)
  - [Development Status](#development-status)
  - [Known Issues](#known-issues)
  - [Version information](#version-information)


## Goal of Mifos Gazelle
The aim of Mifos Gazelle is to provide a trivially simple installation and configuration mechanism for Digital Public Goods (DPGs) DaaS construct.  Initially this is focussed on Mifos applications for Core-Banking and Payment Orchestration and the Mojaloop vNext Beta1 financial transactions switch. The idea is to create a rapidly deployable , understandable and cheap integration to serve as a showcase and a laboratory environment to enable others to build further on these DaaS projects. As the project continues we have a roadmap of additional DPGs, demo cases and other features we are actively implementing, along with looking at how it could be used for production in-cloud and on-premise deployments.

IMPORTANT NOTE: As Mifos Gazelle is a deployment tool we make no statements or opinions on the base DPGs in terms of applicability, security etc we recommend all adopters read DPG base documentation to make their own assessment of these. Likewise at the moment for v1.1.0. release we recommend use solely for development, test and demonstration purposes as security assessment and hardening of Mifos Gazelle regardless of the base DPGs status has not occurred yet.

## Gazelle features (benefits)
- Mifos Gazelle installs each or all 3 DPGs in a reliable , repeatable way using simple bash scripts. 
- The bash scripts are designed to enable developers to understand and modify the configuration of each or all products.
- Enables quick installation of the currrent 3 products, 15 mins or less with capable hardware resources
Fully functioning MifosX , with the addition of tools to simply add additional tenants
Fully functioning vNext (beta1) with integrated demo and test environment, admin UI and pre-loaded demo data
Installed and partially configured PHEE with deployed Web Client(note: see limitations under development status)


## Prerequisites
Before proceeding with the deployment, ensure your system meets the following requirements:

- Ubuntu 22.04 or 24.04 LTS operating systems
- x86_64 or ARM64 architecture
- 24 GB RAM minimum
- 30GB+ free space in home directory
- Non-root user with sudo privileges

Note regarding memory use : 
1. It is possible to deploy each product individually and hence possible to use Mifos Gazelle with far less memory if not all products are deployed at once.

## Quick Start
logged in as non-root user e.g. mifosu user 
```bash
# Navigate to home directory
cd $HOME

# For Installations of the latest release clone the repository (master branch)
git clone --branch master https://github.com/openMF/mifos-gazelle.git

Or

# For Installations of the latest development path clone the repository (dev branch)
git clone --branch dev https://github.com/openMF/mifos-gazelle.git


# Enter the project directory
cd mifos-gazelle

# Deploy all components (MifosX, vNext, and PH-EE)
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


## What to do next 
After the run.sh has finished and ```kubectl get pods -A``` shows all pods and containers running then Mifos Gazelle has finished installing and is ready for use and testing.  Here are some suggestions for what to do next
- Install the k9s kubernetes utility using ``` ~/mifos-gazelle/src/utils/install-k9s.sh ``` then start k9s with ``` ~/local/bin/k9s ```
- Examine the running MifosX database using ``` ~/mifos-gazelle/src/utils/mysql-client-mifos.sh ```
- Examine the running PaymentHub database using  ``` ~/mifos-gazelle/src/utils/mysql-client-mifos.sh -h operationsmysql.paymenthub.svc.cluster.local -p ethieTieCh8ahv -u root -d mysql ```
- Access the deployed applications and consoles for MifosX, vNext and PaymentHub EE see [Accessing Deployed Applications](#accessing-deployed-applications) then browse to http://mifos.mifos.gazelle.test or http://vnextadmin.mifos.gazelle.test or  http://ops.mifos.gazelle.test
- Consult the documentation for the DPGs 
  - vNext using the adminUI and sample account lookup, quotes and transfers : https://github.com/mojaloop/platform-shared-tools/blob/main/packages/deployment/docker-compose-apps/README.md#login-to-the-mojaloop-vnext-admin-ui
  - MifosX for core banking : https://docs.mifos.org/core-banking-and-embedded-finance/core-banking
  - PaymentHub EE : https://mifos.gitbook.io/docs
- if you haven't already join the mifos-gazelle channel on the Mifos Slack at https://mifos.slack.com 

## Execute a transfer from Greenbank to Bluebank (New in v1.1.0)
When Mifos Gazelle 1.1.0 is fully installed with all 3 initial DPGs it is also configured with demonstration data to allow a payment transaction to be initiated by calling paymenthub which then orchestrates the payment flow from the account of a customer in the MifosX Greenbank to the account of a customer in MifosX Bluebank via the vNext beta1 financial transactions switch.  To initiate this transfer use the provided make-payment.sh script. ```./src/utils.make-payment.sh```
Once this payment is succesfully processed you can observe the following

- the BPMN workflow for PayerFundTransfer at https://zeebe-operate.mifos.gazelle.test login is demo/demo. Go to dashboard and click on PayerFundTransfer-greenbank to see the process flow for the transaction. 
  - It will most likely be completed so make sure to click on "finised instances" if it does not immediately show up.  
  - Pay attention to the blue line in the diagram as it shows the path the execution took

- Check PaymentHub operations web UI at https://ops.mifos.gazelle.test/ Go to paymenthub -> transfers to see the transfer details 

- Check the payment stages in vNext switch at https://vnextadmin.mifos.gazelle.test/quotes login admin/superMegaPass 
  - go to quotes -> quotes and click the "quote-id" to get the details for the "quoted" value for the transaction (this is the cusromer amount plus fees and charges etc)
  - examine the transaction, click transfers -> transfers and then click again on the transfer with the amount you enterered in the make-payment.sh script to bring up the payment details 

- Finally check the customer balances in the MifosX core banking. Login as (payer) greenbank or (payee) bluebank using mifos/password at http://mifos.mifos.gazelle.test/ Go to institution -> clients click on the client.  Scroll down and click on the account no. corresponding to the client.
  - note that payer clients start with opening balance of $USD 5000 and this is debited with the amount you specified.  
  - the transaction history is available by clicking -> savings account -> clicking on transactions at the top of the table

## Application Deployment Modes
Choose specific components to deploy using the `-a` flag:

```bash
# Deploy only Mojaloop vNext
sudo ./run.sh -u $USER -m deploy -a vnext

# Deploy only MifosX
sudo ./run.sh -u $USER -m deploy -a mifosx

# Deploy only Payment Hub EE
sudo ./run.sh -u $USER -m deploy -a phee
```

## Cleanup

Remove deployed components:

```bash
# Remove everything including Kubernetes server
sudo ./run.sh -u $USER -m cleanall

# Remove all applications from the Kubernetes server  
sudo ./run.sh -u $USER -m cleanapps

# Remove specific components
sudo ./run.sh -u $USER -m cleanapps -a mifosx  # Remove MifosX
sudo ./run.sh -u $USER -m cleanapps -a phee    # Remove PaymentHub EE
sudo ./run.sh -u $USER -m cleanapps -a vnext   # Remove vNext switch
```

## Accessing Deployed Applications (DPGs) 
Add the following entries to your hosts file on the laptop/desktop system where your web browser is running where <VM-IP> (without the angle brackets) is the IP of the server or VM where Mifos Gazelle has been deployed. If your browser is running on Linux or MacOS then all hosts entries go on one line , if your browser is running on Windows then you need a separate line for each entry. 

Once you have added the hosts below for the DPGs you can access consoles with
- MifosX : http://mifos.mifos.gazelle.test
- vNext : http://vnextadmin.mifos.gazelle.test 
- PaymentHub EE: http://ops.mifos.gazelle.test 



### vNext host Configuration
```bash
# Linux/MacOS (/etc/hosts) 
<VM-IP>  vnextadmin elasticsearch.mifos.gazelle.test kibana.mifos.gazelle.test mongoexpress.mifos.gazelle.test kafkaconsole.mifos.gazelle.test fspiop.mifos.gazelle.test bluebank.mifos.gazelle.test greenbank.mifos.gazelle.test redpanda-console.mifos.gazelle.test

# Windows (C:\Windows\System32\drivers\etc\hosts)
<VM-IP> vnextadmin.mifos.gazelle.test
<VM-IP> elasticsearch.mifos.gazelle.test
<VM-IP> kibana.mifos.gazelle.test
<VM-IP> mongoexpress.mifos.gazelle.test
<VM-IP> kafkaconsole.mifos.gazelle.test
<VM-IP> fspiop.mifos.gazelle.test
<VM-IP> bluebank.mifos.gazelle.test
<VM-IP> greenbank.mifos.gazelle.test
<VM-IP> redpanda-console.mifos.gazelle.test
```

### Payment Hub EE host Configuration

```bash
# Linux/MacOS (/etc/hosts)
<VM-IP> ops.mifos.gazelle.test kibana-phee.mifos.gazelle.test zeebe-operate.mifos.gazelle.test 

# Windows (C:\Windows\System32\drivers\etc\hosts)
<VM-IP> ops.mifos.gazelle.test
<VM-IP> kibana-phee.mifos.gazelle.test
<VM-IP> zeebe-operate.mifos.gazelle.test 

```
### Accessing MifosX
By default the Mifos Gazelle installation now loads tenants  "default", "greenbank" and "bluebank" When logging into Mifos select one of these tenants and use the default user=mifos and password=password. More tenants can be added is you wish.  See [ Adding tenants to MifosX](#adding-tenants-to-mifosx) for instructions on adding more tenants to MifosX database. To change the options for tenants in the web client , modify the FINERACT_PLATFORM_TENANTS_IDENTIFIER in ../src/repos/mifosx/kubernbetes/web-app-deployment.yaml file and redeploy the mifosx app using the Mifos Gazelle run.sh and the -a flag. 

#### Host Configuration

```bash
# Linux/MacOS (/etc/hosts)
<VM-IP> fineract.mifos.gazelle.test mifos.mifos.gazelle.test

# Windows (C:\Windows\System32\drivers\etc\hosts)
<VM-IP> mifos.mifos.gazelle.test
<VM-IP> fineract.mifos.gazelle.test
```

## Helm test
Note the Payment Hub Helm tests are being reconfigured as we continue to work on end to end integration flows, therefore you may get significant errors due to naming at this present point in time (prior to the reconfiguration exercise though they were reporting 90%+ success).
Helm tests are currently enabled/disabled in the config/ph_values.yaml file , look for integration_tests. To execute the helm tests run 
```bash
helm test phee 
```
then examine the logfiles using either k9s or 
```bash
kubectl logs -n paymenthub ph-ee-integration-test-gazelle
```
You can access the results by copying them from the pod to the /tmp directory of the server machine or VM using the script below.  This will place the results into a directory similar to mydir.SzSauX i.e. of the form /tmp/mydir.XXXXXX. You will need to copy this directory from the server/VM to your desktop/laptop to browse the results , look for the subdirectory of tests/test/index.html as the top level for your browser. Note that the pod will time-out after 90 mins and you will need to remove the ph-ee-integration-test-gazelle pod before running helm test phee again. 
```bash
~/mifos-gazelle/src/utils/copy-report-from-pod.sh 
``` 

## More detail on adding tenants to MifosX 
As outlined above by default MifosGazelle deploys MifosX with "default", "greenbank" and "bluebank". 
The process to add additonal tenants to a MifosGazelle deployed MifosX deployment is a 2 part 
1. modify the example tenant configuration file mifos-gazelle/config/mifos-tenant-config.csv adding your chosen tenant names 
2. apply the example tenant configuration to add the new tenants by running (for example) ``` mifos-gazelle/src/utils/utils/update-mifos-tenants.sh -f ./config/mifos-tenant-config.csv ```
3. in k9s locate and kill the fineract-server process in the MifosX namespace (use ```ctrl-k ``` from k9s) it will automatically be restarted by kubernetes. 
When fineract-server is restarted the new tenants schemas tables and artefacts will be created. You can check the progress of the schema generation by looking at the fineract-server pod logs.  Still using k9s, again locate the new fineract-server pod and press  ```l``` for logs when that pod is highlighted.  
1. Once the new fineract-server pod has finished creating the new schema , you can test this by logging in to the MifosX web-client using that tenant. 

## Development Status
Please note that limitations here are entirely those of the Mifos Gazelle configuration, and should not at all be interpreted as issues with the maturity or functionality of the deployed DPGs.  
- Currently PH-EE operations-web UI https://ops.mifos.gazelle.test can access batches and transfers and can create and send batches to bulk. It is not yet clear that the batches are correctly processed on the back end, this of course is being worked on. 
-  ph-ee-integration-test docker image on dockerhub uses the tag  v1.6.2-gazelle and corresponds to the v1.6.2-gazelle branch of the v1.6.2 integration-test repo.  The helm tests as deployed by Gazelle reports approx 90% pass rate. 
- PaymentHub EE v 1.13.0 is being provisioned by Mifos Gazelle and this is set in the config.sh script prior to deployment. This document defines all the sub chart releases that comprise the v1.13.0 release https://mifos.gitbook.io/docs/payment-hub-ee/release-notes/v1.13.0
- There is a lot of tidying up to do once this is better tested, e.g. debug statements to remove and lots of redundant env vars to remove as well as commented out code to remove. 
- It should be straightforward to integrate the Kubernetes operator work ( https://github.com/openMF/mifos-operators ) into this simplified single node deployment and this is planned for a future release 
- vNext Beta1 functions and is tested on ARM64 there is a limitation on Raspberry Pi 4 (or less) with MongoDB due to requirement for ARMv8.2A. Whilst it is untested vNext Beta1 and its associated infrastructure layer deployed by Mifos Gazelle should "just work"  Use ```sudo ./run.sh -u <user> -m deploy -a vnext ``` on a clean install to try. In the future it should be straightforward and is planned to have MifosX and PaymentHub EE also working on ARM and Raspberry PI
- reducing memory usage for demo and test is a high priority project, it is anticipated that the 3 initial DPGs can all run on 16GB or less (i.e. about  50% of the current prerequisite ) 
- The performance testing is still WIP and not fully operational 

## Known Issues
- Currently testing is limited to only systems and environments that meet the pre-requisites 
- Only single instance/node deployment currently supported , there is no technical reason for this other than it is what is currently tested. 
- Some cleanup is likely needed (debug statements, redundant environment variables) but as some of this is in use that will happen in future releases
- PaymentHub EE Kubernetes operator has been developed and will be integrated in future releases
- Updated Operations web integration pending (pending in PH-EE too - https://github.com/openMF/ph-ee-operations-web/pull/98 and https://github.com/openMF/ph-ee-operations-web/pull/99 )
- PaymentHub EE integration with vNext and MifosX is not complete => Operations-Web UI is limited in function
- The postman tests provided by the individual DPGs have not yet been fully adapted to the Mifos Gazelle deployment environment, again this will happen in future releases in a structure fashion. 
- There are some issues on (much) older (Intel/Opteron) hardware with nginx, MongoDB  and ElasticSearch. 
- Reminder Mifos Gazelle deployment of the 3 DPGs is *not at all secure*. (Note this is true no matter of the security status of the underlying DPGs). Security will necessarily become a major focus as we look to more production ready deployments in future releases but it is not yet in-place at all.  

## Version information 

- [RELEASE-NOTES for v1.1.0](./RELEASE_NOTES.md) - see the release notes for version information
  


