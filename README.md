# Mifos Gazelle 
[![Mifos](https://img.shields.io/badge/Mifos-Gazelle-blue)](https://github.com/openMF/mifos-gazelle)
> Deployment utilities for MifosX (including Fineract backend), Payment Hub EE, and Mojaloop vNext (as of December 2024)

## Quick Links
- [Mifos Gazelle README](docs/MIFOS-GAZELLE-README.md) - Deploy and run MifosX, Mifos Payment Hub EE and vNext 
- [vNext README](docs/VNEXT-README.md) - Deploy and run vNext on its own

## Overview
This repository contains the Mifos Gazelle deployment utilities

## Getting Started
1. Review the [Mifos Gazelle README](docs/MIFOS-GAZELLE-README.md) for detailed usage and installation instructions
2. Follow the prerequisites and system requirements


## Repository Structure  (wip) 
```
mifos-gazelle/
├── ARCHITECTURE.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── config/
│   ├── fin_values.yaml
│   ├── mifos-tenant-config.csv
│   ├── nginx_values.yaml
│   ├── ph_values.yaml
├── performance-testing/
│   ├── paymentHubEE.jmx
│   └── README.md
├── postman/
│   └── phee-example-batch-2.csv  
├── repos/
│   ├── mifosx/
│   ├── ph_template/
│   ├── phlabs/
│   └── vnext/
└── src/
    ├── environmentSetup
    ├── deployer 
    ├── commandline/
    ├── configurationManager/
    └── utils/


```

## Additional Resources
- [Contributing Guidelines](CONTRIBUTING.md)
- [License Information](LICENSE.md)
- [Architecture](ARCHITECTURE.md)


