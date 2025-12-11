# Compass Security BloodHound CE Resources

![](./banner.jpg)

This repository contains some useful resources regarding BloodHound CE:

- BloodHound CE Custom Queries [↓](#bloodhound-ce-custom-queries)
- BloodHound Operator Custom Queries [↓](#bloodhound-operator-custom-queries)
- Useful Links [↓](#useful-links)

## BloodHound CE Custom Queries

These queries are used in BloodHound CE to analyze your collected data.

### Direct Usage

You can directly copy the [BloodHound CE Custom
Queries](custom_queries/BloodHound_CE_Custom_Queries.md) from your browser into
your BloodHound CE instance.

### Import

#### Initial Preparation

Install PowerShell on Kali:

```bash
sudo apt -y install powershell
```

You can now start a new PowerShell using `pwsh`.

Clone the `BloodHoundOperator` repository:

```bash
git clone https://github.com/SadProcessor/BloodHoundOperator.git
```

#### Query Import

Load the BloodHoundOperator module:

```powershell
Import-Module /opt/BloodHoundOperator/BloodHoundOperator.ps1
```

Dot-Source (note the `.` in front of the command)
`Create-BloodHoundOperatorSession.ps1` script to create a new
BloodHoundOperator session and make it available in your current PowerShell:

```powershell
. ./scripts/Create-BloodHoundOperatorSession.ps1 -Password 'YourP@ssw0rd'
```

Parameters:

- `-Password`: Password (mandatory, if you don't specify it on the commandline,
  you will be prompted)
- `-Username`: Username (optional, default: `admin`)
- `-Hostname`: Hostname / IP address of the BloodHound API (optional, default:
  `127.0.0.1`)
- `-Port`: Port of the BloodHound API (optional, default: `8080`)

Execute the `Import-BloodHoundCECustomQueries.ps1` script to import the custom
queries:

```powershell
./scripts/Import-BloodHoundCECustomQueries.ps1
```

The imported queries are then shown in BloodHound:

![Custom Queries](./custom_queries/custom_queries.png)

## BloodHound Operator Custom Queries

These queries are used in a BloodHound Operator session, to modify your
collected data.

### Usage

Load the `BloodHoundOperator` module and dot-source the
`Create-BloodHoundOperatorSession.ps1` script as explained above.

Then directly copy the [BloodHound Operator Custom Queries](custom_queries/BloodHound_Operator_Custom_Queries.md)
from your browser into your PowerShell console.

## Useful Links

### BloodHound

- BloodHound Documentation: https://bloodhound.specterops.io/
  - Nodes: https://bloodhound.specterops.io/resources/nodes/overview
  - Edges: https://bloodhound.specterops.io/resources/edges/overview
  - Release Notes: https://bloodhound.specterops.io/resources/release-notes/summary
- BloodHound GitHub: https://github.com/SpecterOps/BloodHound
- SharpHound GitHub: https://github.com/SpecterOps/SharpHound

### Neo4J Cypher

- Neo4J: Cypher Manual: https://neo4j.com/docs/cypher-manual
- Neo4J: Cypher Cheat Sheet: https://neo4j.com/docs/cypher-cheat-sheet/
- Cypher Queries in BloodHound Enterprise:
  https://posts.specterops.io/cypher-queries-in-bloodhound-enterprise-c7221a0d4bb3
- BloodHound: Searching with Cypher:
  https://support.bloodhoundenterprise.io/hc/en-us/articles/16721164740251-Searching-with-Cypher
- BloodHound Documentation: Supported Cypher Syntax:
  https://bloodhound.specterops.io/analyze-data/cypher-supported
