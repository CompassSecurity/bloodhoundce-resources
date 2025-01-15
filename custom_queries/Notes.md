# Notes

## Keep Traversable Edges Up to Date

Copy traversable edges from the
[documentation](https://support.bloodhoundenterprise.io/hc/en-us/articles/26880292005147-Traversable-and-Non-Traversable-Edge-Types),
format them correctly using the following command and replace them in the
custom queries.

```
tr '\n' ' ' | sed -E -e 's/[[:blank:]]/|/g' -e 's/\|+/|/g' -e 's/^/\[:/'  -e 's/\|$/*1\.\.]/'
```

In addition, the used edge types are defined in
[edgeTypes.tsx](https://github.com/SpecterOps/BloodHound/blob/319bb31044b5be6d82243078229631bbcde10de5/packages/javascript/bh-shared-ui/src/views/Explore/ExploreSearch/edgeTypes.tsx).
