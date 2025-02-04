# BloodHound CE Custom Queries

## Domain

### Domains

```cypher
MATCH (d:Domain)
RETURN d
LIMIT 1000
```

### Domains with Machine Account Quota > 0

```cypher
MATCH (d:Domain)
WHERE toInteger(d.machineaccountquota) > 0
RETURN d
LIMIT 1000
```

### Domain Controllers

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(:Computer {isdc: true})
RETURN p
LIMIT 1000
```

## Accounts

### Interesting Objects by Keywords

```cypher
UNWIND ['admin', 'empfindlich', 'geheim', 'important', 'azure', 'MSOL', 'kennwort', 'pass', 'secret', 'sensib', 'sensitiv', 'wichtig', 'backdoor', 'honey'] AS word
MATCH p = (:Domain)-[:Contains*1..]->(b:Base)
WHERE (toLower(b.name) CONTAINS toLower(word))
  OR (toLower(b.description) CONTAINS toLower(word))
RETURN p
LIMIT 1000
```

### Users with Password in Description

```cypher
UNWIND ['pass', 'pwd', 'kenn', 'login', 'cred'] AS word
MATCH p = (:Domain)-[:Contains*1..]->(u:User)
WHERE (toLower(u.description) CONTAINS toLower(word))
RETURN p
LIMIT 1000
```

### Users with Password Stored in Cleartext Password Fields

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(u:User)
WHERE u.userpassword <> ""
  OR u.unixpassword <> ""
  OR u.sfupassword <> ""
  OR u.unicodepassword <> ""
RETURN p
LIMIT 1000
```

### Users with Password Stored Using Reversible Encryption

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(:Base {encryptedtextpwdallowed: true})
RETURN p
LIMIT 1000
```

### Users with Password Not Requred

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(:Base {passwordnotreqd: true})
RETURN p
LIMIT 1000
```

### Users with Password Never Expires

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(:Base {pwdneverexpires: true})
RETURN p
LIMIT 1000
```

### Users with Same Name in Other Domain

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(u1:User),(u2:User)
WHERE u1.samaccountname = u2.samaccountname
  AND u1.domain <> u2.domain
RETURN p
LIMIT 1000
```

### All Sessions of All Users

```cypher
MATCH p = (:Computer)-[:HasSession*1..]->(:User)
RETURN p
LIMIT 1000
```

## Privileged Accounts

### Tier 0 Objects

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(n:Base)
WHERE "admin_tier_0" IN split(n.system_tags, " ")
RETURN p
LIMIT 1000
```

### Tier 0 Users

```cypher
MATCH p = (u:User)-[:MemberOf]->(:Base)
WHERE "admin_tier_0" IN split(u.system_tags, " ")
RETURN p
LIMIT 1000
```

### Tier 0 Computers

```cypher
MATCH p = (c:Computer)-[:MemberOf]->(:Base)
WHERE "admin_tier_0" IN split(c.system_tags, " ")
RETURN p
LIMIT 1000
```

### Users in Protected Users Group

```cypher
MATCH p = (:Base)-[:MemberOf*1..]->(:Group {samaccountname: "Protected Users"})
RETURN p
LIMIT 1000
```

### Users which Cannot be Delegated ("Account is sensitive and cannot be delegated")

```cypher
MATCH p = (:Base {sensitive: true})-[:MemberOf*1..]->(:Group)
RETURN p
LIMIT 1000
```

### AdminTo Edges

```cypher
MATCH p = (u)-[:AdminTo]->(:Computer)
RETURN p
LIMIT 1000
```

### Tier 0 Users Logins on Non-Tier 0

```cypher
MATCH p = (c:Computer)-[:HasSession*1..]->(u:User)
WHERE "admin_tier_0" IN split(u.system_tags, " ")
  AND (NOT "admin_tier_0" IN split(c.system_tags, " ") OR c.system_tags is NULL)
RETURN p
LIMIT 1000
```

### Non-Tier 0 Administrators

```cypher
MATCH p = (b:Base)-[:AdminTo]->(:Computer)
WHERE NOT "admin_tier_0" IN split(b.system_tags, " ") OR b.system_tags is NULL
RETURN p
LIMIT 1000
```

### Non-Tier 0 DCSync Accounts

```cypher
MATCH p = allShortestPaths((b:Base)-[:MemberOf|:GenericAll|:DCSync*1..]->(d:Domain))
WHERE b <> d
  AND NOT "admin_tier_0" IN split(b.system_tags, " ") OR b.system_tags is NULL
RETURN p
LIMIT 1000
```

### Non-Tier 0 LAPS Read

```cypher
MATCH p = (b:Base)-[:AllExtendedRights|ReadLAPSPassword]->(:Computer)
WHERE NOT "admin_tier_0" IN split(b.system_tags, " ") OR b.system_tags is NULL
RETURN p
LIMIT 1000
```

### Non-Tier 0 RDP Access

```cypher
MATCH p = (b:Base)-[:AdminTo]->(:Computer)
WHERE NOT "admin_tier_0" IN split(b.system_tags, " ") OR b.system_tags is NULL
RETURN p
LIMIT 1000
```

## Computer Accounts

### Computer without LAPS

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(:Base {haslaps: false, isdc: false})
RETURN p
LIMIT 1000
```

### Computer in Tier 0 Groups

```cypher
MATCH p = (:Computer {isdc: false})-[:MemberOf*1..]->(g:Group)
WHERE "admin_tier_0" IN split(g.system_tags, " ")
RETURN p
LIMIT 1000
```

### Computers Admin to Computers (direct)

```cypher
MATCH p = (:Computer)-[:MemberOf|HasSIDHistory*0..]->(g)-[:AdminTo]->(:Computer)
RETURN p
LIMIT 1000
```

### Computers Admin to Computers (indirect)

```cypher
MATCH p = (:Computer)-[:MemberOf*1..]->(:Base)-[:AdminTo*1..]->(:Computer)
RETURN p
LIMIT 100
```

### Computers Admin to Computers (direct and indirect but with superflous group membership information)

This query also returns all computers which are in a group, which is superflous information.

```cypher
MATCH p = allShortestPaths((c:Computer)-[:AdminTo|MemberOf*1..]->(b:Base))
WHERE c <> b
RETURN p
LIMIT 100
```

## Kerberos

### Kerberoastable Users (Accounts with SPN Set)

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(b:Base {hasspn: true})
WHERE b.samaccountname <> "krbtgt"
RETURN p
LIMIT 1000
```

### Kerberoastable Users in Tier 0 Groups

```cypher
MATCH p = shortestPath((:User {hasspn: true})-[:MemberOf*1..]->(g:Group))
WHERE "admin_tier_0" IN split(g.system_tags, " ")
RETURN p
LIMIT 1000
```

### Shortest Path from Kerberoastable Users to Tier 0

```cypher
MATCH p = shortestPath((u:User {hasspn: true})-[:ADCSESC1|ADCSESC10a|ADCSESC10b|ADCSESC13|ADCSESC3|ADCSESC4|ADCSESC6a|ADCSESC6b|ADCSESC9a|ADCSESC9b|AddAllowedToAct|AddKeyCredentialLink|AddMember|AddSelf|AdminTo|AllExtendedRights|AllowedToAct|AllowedToDelegate|CanPSRemote|CanRDP|CoerceToTGT|Contains|DCFor|DCSync|DumpSMSAPassword|ExecuteDCOM|ForceChangePassword|GenericAll|GenericWrite|GoldenCert|GPLink|HasSession|HasSIDHistory|MemberOf|Owns|ReadGMSAPassword|ReadLAPSPassword|SQLAdmin|SyncedToEntraUser|SyncLAPSPassword|TrustedBy|WriteAccountRestrictions|WriteDacl|WriteGPLink|WriteOwner|WriteSPN*1..]->(b:Base))
WHERE u <> b
  AND u.samaccountname <> "krbtgt"
  AND "admin_tier_0" IN split(b.system_tags, " ")
RETURN p
LIMIT 1000
```

- This query contains all traversable edges.

### AS-REP Roastable Users (Accounts which do Not Requre Pre-Authentication)

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(:Base {dontreqpreauth: true})
RETURN p
LIMIT 1000
```

### Unconstrained Delegation Systems

```cypher
MATCH p = ()-[:CoerceToTGT]->(:Domain)
RETURN p
LIMIT 1000
```

### Shortest Path to Unconstrained Delegation Systems except DCs

```cypher
MATCH p = shortestPath((b:Base)-[:ADCSESC1|ADCSESC10a|ADCSESC10b|ADCSESC13|ADCSESC3|ADCSESC4|ADCSESC6a|ADCSESC6b|ADCSESC9a|ADCSESC9b|AddAllowedToAct|AddKeyCredentialLink|AddMember|AddSelf|AdminTo|AllExtendedRights|AllowedToAct|AllowedToDelegate|CanPSRemote|CanRDP|CoerceToTGT|Contains|DCFor|DCSync|DumpSMSAPassword|ExecuteDCOM|ForceChangePassword|GenericAll|GenericWrite|GoldenCert|GPLink|HasSession|HasSIDHistory|MemberOf|Owns|ReadGMSAPassword|ReadLAPSPassword|SQLAdmin|SyncedToEntraUser|SyncLAPSPassword|TrustedBy|WriteAccountRestrictions|WriteDacl|WriteGPLink|WriteOwner|WriteSPN*1..]->(c:Computer {isdc: false, unconstraineddelegation: true}))
WHERE b<>c
RETURN p
LIMIT 1000
```

- This query contains all traversable edges.

### Constrained Delegation

```cypher
MATCH p = (:Base)-[:AllowedToDelegate*1..]->(:Computer)
RETURN p
LIMIT 1000
```

### Constrained Delegation with Protocol Transition

```cypher
MATCH p = (:Base {trustedtoauth: true})-[:AllowedToDelegate*1..]->(:Computer)
RETURN p
LIMIT 1000
```

### Constrained Delegation without Protocol Transition

```cypher
MATCH p = (:Base {trustedtoauth: false})-[:AllowedToDelegate*1..]->(:Computer)
RETURN p
LIMIT 1000
```

### Resource Based Contrained Delegation (RBCD)

```cypher
MATCH p = (:Base)-[:AllowedToAct*1..]->(:Base)
RETURN p
LIMIT 1000
```

### Configure Resource Based Contrained Delegation (RBCD)

```cypher
MATCH p = (:Base)-[:AddAllowedToAct*1..]->(:Base)
RETURN p
LIMIT 1000
```

## Owned Objects

### Owned Objects

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(b:Base)
WHERE "owned" IN split(b.system_tags, " ")
RETURN p
LIMIT 1000
```

### Owned Objects and Their Group

```cypher
MATCH p = allShortestPaths((b1:Base)-[:MemberOf]->(b2:Base))
WHERE "owned" IN split(b1.system_tags, " ")
  AND b1 <> b2
RETURN p
LIMIT 1000
```

## Shortest Path

### All Shortest Paths from Owned Principals to Tier 0

```cypher
MATCH p = allShortestPaths((u:User)-[:ADCSESC1|ADCSESC10a|ADCSESC10b|ADCSESC13|ADCSESC3|ADCSESC4|ADCSESC6a|ADCSESC6b|ADCSESC9a|ADCSESC9b|AddAllowedToAct|AddKeyCredentialLink|AddMember|AddSelf|AdminTo|AllExtendedRights|AllowedToAct|AllowedToDelegate|CanPSRemote|CanRDP|CoerceToTGT|Contains|DCFor|DCSync|DumpSMSAPassword|ExecuteDCOM|ForceChangePassword|GenericAll|GenericWrite|GoldenCert|GPLink|HasSession|HasSIDHistory|MemberOf|Owns|ReadGMSAPassword|ReadLAPSPassword|SQLAdmin|SyncedToEntraUser|SyncLAPSPassword|TrustedBy|WriteAccountRestrictions|WriteDacl|WriteGPLink|WriteOwner|WriteSPN*1..]->(b:Base))
WHERE "owned" IN split(u.system_tags, " ")
  AND "admin_tier_0" IN split(b.system_tags, " ")
RETURN p
LIMIT 1000
```

- This query contains all traversable edges.

### All Shortest Paths from Low Privileged Groups to Tier 0

```cypher
UNWIND ['-S-1-5-11', '-S-1-5-32-554', '-S-1-1-0', '-513', '-S-1-5-32-545'] AS group
MATCH p = allShortestPaths((g:Group)-[:ADCSESC1|ADCSESC10a|ADCSESC10b|ADCSESC13|ADCSESC3|ADCSESC4|ADCSESC6a|ADCSESC6b|ADCSESC9a|ADCSESC9b|AddAllowedToAct|AddKeyCredentialLink|AddMember|AddSelf|AdminTo|AllExtendedRights|AllowedToAct|AllowedToDelegate|CanPSRemote|CanRDP|CoerceToTGT|Contains|DCFor|DCSync|DumpSMSAPassword|ExecuteDCOM|ForceChangePassword|GenericAll|GenericWrite|GoldenCert|GPLink|HasSession|HasSIDHistory|MemberOf|Owns|ReadGMSAPassword|ReadLAPSPassword|SQLAdmin|SyncedToEntraUser|SyncLAPSPassword|TrustedBy|WriteAccountRestrictions|WriteDacl|WriteGPLink|WriteOwner|WriteSPN*1..]->(b:Base))
WHERE g <> b
  AND g.objectid ENDS WITH group
  AND "admin_tier_0" IN split(b.system_tags, " ")
RETURN p
LIMIT 1000
```

- This query contains all traversable edges.

Used group SIDs:

- `-S-1-5-11`: Authenticated Users
- `-S-1-5-32-554`: Pre-Windows 2000 Compatible Access
- `-S-1-1-0`: Everyone
- `-513`: Domain Users
- `-S-1-5-32-545`: Users

### All Shortest Paths to Tier 0

```cypher
MATCH p = allShortestPaths((b1:Base)-[:ADCSESC1|ADCSESC10a|ADCSESC10b|ADCSESC13|ADCSESC3|ADCSESC4|ADCSESC6a|ADCSESC6b|ADCSESC9a|ADCSESC9b|AddAllowedToAct|AddKeyCredentialLink|AddMember|AddSelf|AdminTo|AllExtendedRights|AllowedToAct|AllowedToDelegate|CanPSRemote|CanRDP|CoerceToTGT|Contains|DCFor|DCSync|DumpSMSAPassword|ExecuteDCOM|ForceChangePassword|GenericAll|GenericWrite|GoldenCert|GPLink|HasSession|HasSIDHistory|MemberOf|Owns|ReadGMSAPassword|ReadLAPSPassword|SQLAdmin|SyncedToEntraUser|SyncLAPSPassword|TrustedBy|WriteAccountRestrictions|WriteDacl|WriteGPLink|WriteOwner|WriteSPN*1..]->(b2:Base))
WHERE b1 <> b2
  AND "admin_tier_0" IN split(b2.system_tags, " ")
RETURN p
LIMIT 1000
```

- This query contains all traversable edges.

### All Shortest Paths From Specific Account to Computers or Users (Adjust Query)

```cypher
WITH "tmassie@child.testlab.local" AS username
UNWIND ['Computer', 'User'] AS type
MATCH p = allShortestPaths((u:User)-[:ADCSESC1|ADCSESC10a|ADCSESC10b|ADCSESC13|ADCSESC3|ADCSESC4|ADCSESC6a|ADCSESC6b|ADCSESC9a|ADCSESC9b|AddAllowedToAct|AddKeyCredentialLink|AddMember|AddSelf|AdminTo|AllExtendedRights|AllowedToAct|AllowedToDelegate|CanPSRemote|CanRDP|CoerceToTGT|Contains|DCFor|DCSync|DumpSMSAPassword|ExecuteDCOM|ForceChangePassword|GenericAll|GenericWrite|GoldenCert|GPLink|HasSession|HasSIDHistory|MemberOf|Owns|ReadGMSAPassword|ReadLAPSPassword|SQLAdmin|SyncedToEntraUser|SyncLAPSPassword|TrustedBy|WriteAccountRestrictions|WriteDacl|WriteGPLink|WriteOwner|WriteSPN*1..]->(b:Base))
WHERE u <> b
  AND toLower(u.userprincipalname) = toLower(username)
  AND (type IN LABELS(u))
RETURN p
LIMIT 1000
```

- This query contains all traversable edges.

### Shortest Paths to Domain (including Computers)

```cypher
MATCH p = allShortestPaths((b)-[*1..]->(:Domain))
WHERE (b:User OR b:Computer)
RETURN p
LIMIT 1000
```

### Shortest Paths to no LAPS

```cypher
MATCH p = allShortestPaths((b)-[*1..]->(c:Computer))
WHERE b <> c
  AND (b:User OR b:Computer)
  AND c.haslaps = false
RETURN p
LIMIT 1000
```

### Shortest Paths from Kerberoastable Users to Computers

```cypher
MATCH p = allShortestPaths((u:User {hasspn: true})-[*1..]->(:Computer))
WHERE u.samaccountname <> "krbtgt"
RETURN p
LIMIT 1000
```

### Shortest Paths from Kerberoastable Users to High Value Targets

```cypher
MATCH p = allShortestPaths((u:User {hasspn: true})-[*1..]->(b))
WHERE u <> b
  AND b.system_tags CONTAINS "admin_tier_0"
  AND u.samaccountname <> "krbtgt"
RETURN p
LIMIT 1000
```

### Shortest Paths from Owned Principals (including everything)

```cypher
MATCH p = allShortestPaths((u:User)-[*1..]->(b))
WHERE u <> b
  AND "owned" IN split(u.system_tags, " ")
RETURN p
LIMIT 1000
```

### Shortest Paths from Owned Principals to Domain

```cypher
MATCH p = allShortestPaths((b)-[*1..]->(:Domain))
WHERE "owned" IN split(b.system_tags, " ")
RETURN p
LIMIT 1000
```

### Shortest Paths from Owned Principals to High Value Targets

```cypher
MATCH p = allShortestPaths((b1)-[*1..]->(b2))
WHERE "owned" IN split(b1.system_tags, " ")
  AND "admin_tier_0" IN split(b2.system_tags, " ")
RETURN p
LIMIT 1000
```

### Shortest Paths from Owned Principals to no LAPS

```cypher
MATCH p = allShortestPaths((b)-[*1..]->(c:Computer {haslaps: false}))
WHERE b <> c
  AND "owned" IN split(b.system_tags, " ")
RETURN p
LIMIT 1000
```

### Shortest Paths from Domain Users and Domain Computers (including everything)

```cypher
MATCH p = allShortestPaths((g:Group)-[*1..]->(b))
WHERE g <> b
  AND (g.objectid =~ "(?i).*S-1-5-.*-513" OR g.objectid =~ "(?i).*S-1-5-.*-515")
RETURN p
LIMIT 1000
```

### Shortest Paths from no Signing to Domain

- Requires Set HasNoSMBSigning Members

```cypher
MATCH p = allShortestPaths((c:Computer)-[*1..]->(:Domain))
WHERE "hasnosmbsigning" IN split(c.user_tags, " ")
RETURN p
LIMIT 1000
```

### Shortest Paths from no Signing to High Value Targets

- Requires Set HasNoSMBSigning Members

```cypher
MATCH p = allShortestPaths((c:Computer)-[*1..]->(b))
WHERE c <> b
  AND "hasnosmbsigning" IN split(c.user_tags, " ")
  AND "admin_tier_0" IN split(b.system_tags, " ")
RETURN p
LIMIT 1000
```

## DACL Abuse

### LAPS Passwords Readable by Non-Admin

```cypher
MATCH p = (u:User)-[:MemberOf*1..]->(:Group)-[:GenericAll]->(:Computer {haslaps:true})
WHERE NOT "admin_tier_0" IN split(u.system_tags, " ") OR u.system_tags is NULL
RETURN p
LIMIT 1000
```

### LAPS Passwords Readable by Owned Principals

```cypher
MATCH p = (u)-[:MemberOf*1..]->(:Group)-[:GenericAll]->(t:Computer {haslaps:true})
WHERE "owned" IN split(u.system_tags, " ")
RETURN p
LIMIT 1000
```

### ACLs to Computers (excluding High Value Targets)

```cypher
MATCH p = (b)-[{isacl: true}]->(:Computer)
WHERE (b:User OR b:Computer OR b:Group)
  AND (NOT "admin_tier_0" IN split(b.system_tags, " ") OR b.system_tags is NULL)
RETURN p
LIMIT 1000
```

### Group Delegated Outbound Object Control from Owned Principals

```cypher
MATCH p = (b1)-[:MemberOf*1..]->(:Group)-[{isacl: true}]->(b2)
WHERE "owned" IN split(b1.system_tags, " ")
RETURN p
LIMIT 1000
```

### Dangerous Rights for Groups under Domain Users

```cypher
UNWIND ['-S-1-5-11', '-S-1-5-32-554', '-S-1-1-0', '-513', '-S-1-5-32-545'] AS group
MATCH p = (g:Group)-[:MemberOf*1..]->(:Group)-[:Owns|WriteDacl|GenericAll|WriteOwner|ExecuteDCOM|GenericWrite|AllowedToDelegate|ForceChangePassword]->(b)
WHERE g.objectid ENDS WITH group
RETURN p
LIMIT 1000
```

Used group SIDs:

- `-S-1-5-11`: Authenticated Users
- `-S-1-5-32-554`: Pre-Windows 2000 Compatible Access
- `-S-1-1-0`: Everyone
- `-513`: Domain Users
- `-S-1-5-32-545`: Users

## GPOs

### Interesting GPOs by Keyword

```cypher
UNWIND ["360totalsecurity", "access", "acronis", "adaware", "admin", "admin", "aegislab", "ahnlab", "alienvault", "altavista", "amsi", "anti-virus", "antivirus", "antiy", "apexone", "applock", "arcabit", "arcsight", "atm", "atp", "av", "avast", "avg", "avira", "baidu", "baiduspider", "bank", "barracuda", "bingbot", "bitdefender", "bluvector", "canary", "carbon", "carbonblack", "certificate", "check", "checkpoint", "citrix", "clamav", "code42", "comodo", "countercept", "countertack", "credential", "crowdstrike", "custom", "cyberark", "cybereason", "cylance", "cynet360", "cyren", "darktrace", "datadog", "defender", "druva", "drweb", "duckduckbot", "edr", "egambit", "emsisoft", "encase", "endgame", "ensilo", "escan", "eset", "exabot", "exception", "f-secure", "f5", "falcon", "fidelis", "fireeye", "firewall", "fix", "forcepoint", "forti", "fortigate", "fortil", "fortinet", "gdata", "gravityzone", "guard", "honey", "huntress", "identity", "ikarussecurity", "insight", "ivanti", "juniper", "k7antivirus", "k7computing", "kaspersky", "kingsoft", "kiosk", "laps", "lightcyber", "logging", "logrhythm", "lynx", "malwarebytes", "manageengine", "mass", "mcafee", "microsoft", "mj12bot", "msnbot", "nanoav", "nessus", "netwitness", "office365", "onedrive", "orion", "palo", "paloalto", "paloaltonetworks", "panda", "pass", "powershell", "proofpoint", "proxy", "qradar", "rdp", "rsa", "runasppl", "sandbox", "sap", "scanner", "scanning", "sccm", "script", "secret", "secureage", "secureworks", "security", "sensitive", "sentinel", "sentinelone", "slurp", "smartcard", "sogou", "solarwinds", "sonicwall", "sophos", "splunk", "superantispyware", "symantec", "tachyon", "temporary", "tencent", "totaldefense", "transfer", "trapmine", "trend micro", "trendmicro", "trusteer", "trustlook", "uac", "vdi", "virusblokada", "virustotal", "virustotalcloud", "vpn", "vuln", "webroot", "whitelist", "wifi", "winrm", "workaround", "yubikey", "zillya", "zonealarm", "zscaler"] as word
MATCH p = (g:GPO)-[:GPLink*1..]->(:Base)
WHERE toLower(g.name) CONTAINS toLower(word)
RETURN p
LIMIT 1000
```

### GPO Permissions of Non-Admin Principals

```cypher
MATCH p = (u:User)-[:AddMember|AddSelf|WriteSPN|AddKeyCredentialLink|AllExtendedRights|ForceChangePassword|GenericAll|GenericWrite|WriteDacl|WriteOwner|Owns]->(:GPO)
WHERE NOT 'admin_tier_0' IN split(u.system_tags, ' ') OR u.system_tags is NULL
RETURN p
LIMIT 1000
```

## ADCS

### All CAs

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(:EnterpriseCA)
RETURN p
LIMIT 1000
```

### All Certificate Templates

```cypher
MATCH p = (:Domain)-[:Contains*1..]->(n:CertTemplate)
RETURN p
LIMIT 1000
```

### All Published Templates

```cypher
MATCH p = (ct:CertTemplate)-[:PublishedTo]->(:EnterpriseCA)
RETURN p
LIMIT 1000
```

### ESC1/3/4/14 not from Tier-0

```cypher
MATCH p = (b)-[:ADCSESC1|ADCSESC3|ADCSESC4|ADCSESC13]->()
WHERE NOT "admin_tier_0" IN split(b.system_tags, " ") OR b.system_tags is NULL
RETURN p
LIMIT 1000
```

### ESC15 (EKUwu)

- Note: Probably patched so false positives will happen.

```cypher
MATCH p = (:Base)-[:Enroll|AllExtendedRights]->(ct:CertTemplate)-[:PublishedTo]->(:EnterpriseCA)-[:TrustedForNTAuth]->(:NTAuthStore)-[:NTAuthStoreFor]->(:Domain)
WHERE ct.enrolleesuppliessubject = True
  AND ct.authenticationenabled = False
  AND ct.requiresmanagerapproval = False
  AND ct.schemaversion = 1
RETURN p
LIMIT 1000
```

- Query Source: Twitter [@SpecterOps](https://x.com/SpecterOps/status/1844800558151901639)
- More information: https://trustedsec.com/blog/ekuwu-not-just-another-ad-cs-esc
