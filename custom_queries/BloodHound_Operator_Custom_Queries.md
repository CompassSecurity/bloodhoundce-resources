# BloodHound Operator Custom Queries

## On-Prem

### Set Server Operators, Account Operators and Print Operators as High Value Targets

These groups were included as high value targets in the old BH.

```powershell
$TierZero = BHNodeGroup | ? name -eq 'Admin Tier Zero'
BHPath "MATCH (g:Group) WHERE (g.system_tags IS NULL OR NOT 'admin_tier_0' IN split(g.system_tags, ' ')) AND (g.objectid =~ '(?i).*S-1-5-.*-548' OR g.objectid =~ '(?i).*S-1-5-.*-549' OR g.objectid =~ '(?i).*S-1-5-.*-550') RETURN g" | Add-BHNodeToNodeGroup -NodeGroupID $TierZero.id -force
```

### Set DCSync Principals as High Value Targets

```powershell
$TierZero = BHNodeGroup | ? name -eq 'Admin Tier Zero'
BHPath "MATCH (n)-[:DCSync|AllExtendedRights|GenericAll]->(:Domain) WHERE (n.system_tags IS NULL OR NOT 'admin_tier_0' IN split(n.system_tags, ' ')) RETURN n" | Add-BHNodeToNodeGroup -NodeGroupID $TierZero.id -force
```

### Set DCSync Principals as High Value Targets with GetChanges and GetChangesAll Edges

This query is probably not necessary as BloodHound will create the abusable edge DCSync if GetChanges and GetChangesAll are given.

```powershell
$TierZero = BHNodeGroup | ? name -eq 'Admin Tier Zero'
BHPath "MATCH (n)-[:DCSync|AllExtendedRights|GenericAll|GetChanges|GetChangesAll]->(:Domain) WHERE (n.system_tags IS NULL OR NOT 'admin_tier_0' IN split(n.system_tags, ' ')) RETURN n" | Add-BHNodeToNodeGroup -NodeGroupID $TierZero.id -force
```

### Set Unconstrained Delegation Principals as High Value Targets

```powershell
$TierZero = BHNodeGroup | ? name -eq 'Admin Tier Zero'
BHPath "MATCH (n) WHERE (n:User OR n:Computer) AND n.unconstraineddelegation = true AND (n.system_tags IS NULL OR NOT 'admin_tier_0' IN split(n.system_tags, ' ')) RETURN n" | Add-BHNodeToNodeGroup -NodeGroupID $TierZero.id -force
```

### Set Local Admin or Reset Password Principals as High Value Targets

```powershell
$TierZero = BHNodeGroup | ? name -eq 'Admin Tier Zero'
BHPath "MATCH (n)-[:AdminTo|ForceChangePassword]->(b) WHERE (n.system_tags IS NULL OR NOT 'admin_tier_0' IN split(n.system_tags, ' ')) RETURN n" | Add-BHNodeToNodeGroup -NodeGroupID $TierZero.id -force
```

### Set Principals with Privileges on Computers as High Value Targets

```powershell
$TierZero = BHNodeGroup | ? name -eq 'Admin Tier Zero'
BHPath "MATCH (n)-[:AllowedToDelegate|ExecuteDCOM|ForceChangePassword|GenericAll|GenericWrite|Owns|WriteDacl|WriteOwner]->(:Computer) WHERE (n.system_tags IS NULL OR NOT 'admin_tier_0' IN split(n.system_tags, ' ')) RETURN n" | Add-BHNodeToNodeGroup -NodeGroupID $TierZero.id -force
```

### Set Principals with Privileges on Cert Publishers as High Value Target

```powershell
$TierZero = BHNodeGroup | ? name -eq 'Admin Tier Zero'
BHPath "MATCH (n)-[:GenericAll|GenericWrite|MemberOf|Owns|WriteDacl|WriteOwner]->(g:Group) WHERE g.objectid =~ '(?i).*S-1-5-21-.*-517' AND (n.system_tags IS NULL OR NOT 'admin_tier_0' IN split(n.system_tags, ' ')) RETURN n" | Add-BHNodeToNodeGroup -NodeGroupID $TierZero.id -force
```

### Set Members of High Value Targets Groups as High Value Targets

```powershell
$TierZero = BHNodeGroup | ? name -eq 'Admin Tier Zero'
BHPath "MATCH (n)-[:MemberOf*1..]->(g:Group) WHERE (n.system_tags IS NULL OR NOT 'admin_tier_0' IN split(n.system_tags, ' ')) AND g.system_tags CONTAINS 'admin_tier_0' RETURN n" | Add-BHNodeToNodeGroup -NodeGroupID $TierZero.id -force
```

### Set HasNoSMBSigning Members

This creates a user Node Group called HasNoSMBSigning. Provide a file with computer names like "pc1.domain.local". One entry per line.

```powershell
New-BHNodeGroup HasNoSMBSigning
$HasNoSMBSigning = BHNodeGroup | ? name -eq 'HasNoSMBSigning'
foreach($line in [System.IO.File]::ReadLines("./no-smb-computers.txt"))
{
       BHSearch Computer $line | Add-BHNodeToNodeGroup -NodeGroupID $HasNoSMBSigning.id -force
}
```

### Remove Inactive Users and Computers from High Value Targets

Inactive = last logon > 180 days.

```powershell
$TierZero = BHNodeGroup | ? name -eq 'Admin Tier Zero'
BHPath "MATCH (uc) WHERE uc.system_tags CONTAINS 'admin_tier_0' AND ((uc:User AND uc.enabled = false) OR (uc:Computer AND ((uc.enabled = false) OR (uc.lastlogon > 0 AND uc.lastlogon < (TIMESTAMP() / 1000 - 15552000)) OR (uc.lastlogontimestamp > 0 AND uc.lastlogontimestamp < (TIMESTAMP() / 1000 - 15552000))))) RETURN uc" | Remove-BHNodeFromNodeGroup -NodeGroupID $TierZero.id -force
```
