---
# Release notes for Mifos Gazelle v1.1.0 
---

# Major New features

* Support for ARM64
* End to End demonstration of Payment from Mifos Tenant Greenbank to Mifos 
* Tenant Bluebank using PHEE, Mifos X, and vNext
* Observability including Camunda workflows with Camunda Operate
* Reduced Memory Utilisation for all components required memory now < 24GB

## MifosX 
### fineract: 1.11.0
* this image is built outside of Mifos infrastructure so it is hard to tell exact history and status
### mifos web-app: 
* dockerhub openmf/web-app:dev-dc1f82e 
* this image is built outside of Mifos infrastructure so it is hard to tell exact history and status

## PaymentHub EE (-gazelle-1.1.0)

### ph-ee-env-template: v1.13.0-gazelle-1.1.0

* base is v1.13.0 (see https://mifos.gitbook.io/docs/payment-hub-ee/release-notes/v1.13.0 )

### ph-ee-connector-channel: v1.11.0-gazelle-1.1.0 

* base is : v1.11.0 

### ph-ee-importer-rdbms: v1.13.1-gazelle-1.1.0

* base is v1.13.1

## ph-ee-importer-es: 1.14.0

* Not currently deployed by Mifos Gazelle 1.1.0
* ARM image not yet published

### ph-ee-operations-app: v1.17.1-gazelle-1.1.0
* base is v1.17.1

### ph-ee-connector-slcb: v1.5.0

* Not currently deployed by Mifos Gazelle 1.1.0 

### ph-ee-zeebe-ops: v1.4.0-gazelle-1.1.0 

* base is v1.4.0 

### ph-ee-operations-web: gazelle-1.1.0

* base is master
* unlike most other PHEE components which are based from the paymenthub EE v1.13.0 release, this component is based on master and is now a number of commits ahead of master branch.

### ph-ee-bulk-processor: v1.12.1-gazelle-1.1.0 

* base is v1.12.1 
* this is the connector_bulk subchart of the ph-ee-engine helm parent chart 

### ph-ee-connector-bulk: v1.1.0

* base is 
* this is the ph-ee-connector subchart of the ph-ee-engine helm parent chart

### ph-ee-exporter: v1.2.0

* Not currently deployed by Mifos Gazelle 1.1.0
* ARM image not yet published

### ph-ee-connector-ams-paygops: v1.6.1

* Not currently deployed by Mifos Gazelle 1.1.0
* ARM image not yet published

### ph-ee-connector-ams-pesa: v1.3.1

* Not currently deployed by Mifos Gazelle 1.1.0
* ARM image not yet published

### ph-ee-connector-mpesa: v1.7.0

* Not currently deployed by Mifos Gazelle 1.1.0
* ARM image not yet published

### ph-ee-notifications: v1.4.0-gazelle-1.1.0

* base is v1.4.0

### ph-ee-connector-common: v1.8.1-gazelle

* base is v1.8.1 , v1.8.1-gazelle has no functional updates but is available in the Mifos JFrog artifactory repository and has been moved to JDK17. 
* other PHEE components have been updated to point to this version of connector-common where the java and springboot versions allow but there are other older versions in the Mifos JFrog too (see : http://mifos.jfrog.io)

### ph-ee-connector-ams-mifos: v1.7.0-gazelle-v1.1.0

* base is v1.7.0

### ph-ee-connector-mojaloop-java: gazelle-v1.1.0

* base is master.  
* unlike most other PHEE components which are based from the paymenthub EE v1.13.0 release, this component is now a number of commits ahead of master branch.

### ph-ee-identity-account-mapper: v1.6.0-gazelle-1.1.0
* base is v1.6.0

### ph-ee-connector-mock-payment-schema: v1.6.0-gazelle-1.1.0

* base is v1.6.0

### ph-ee-connector-gsma-mm: v1.3.0

* Not currently deployed by Mifos Gazelle 1.1.0
* ARM image not yet published

### message-gateway: v1.2.0

* Not currently deployed by Mifos Gazelle 1.1.0
* ARM image not yet published

### ph-ee-vouchers: v1.3.0, v1.3.1

* Not currently deployed by Mifos Gazelle 1.1.0
* ARM image not yet published

### ph-ee-connector-crm: v1.1.0

* Not currently deployed by Mifos Gazelle 1.1.0
* ARM image not yet published

### ph-ee-bill-pay: v1.1.0

* Not currently deployed by Mifos Gazelle 1.1.0
* ARM image not yet published

### ph-ee-integration-test: v1.6.0-gazelle-1.1.0

* base is v1.6.2 

### ph-ee-env-labs: 

* not used by gazelle 1.1.0 


