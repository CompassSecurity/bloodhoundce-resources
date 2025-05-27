# Notes

## Keep Traversable Edges Up to Date

Copy traversable edges from the
[documentation](https://bloodhound.specterops.io/resources/edges/traversable-edges),
format them correctly using the following command and replace them in the
custom queries.

```
tr '\n' ' ' | sed -E -e 's/[[:blank:]]/|/g' -e 's/\|+/|/g' -e 's/^/\[:/'  -e 's/\|$/*1\.\.]/'
```

In addition, the used edge types are documented here: https://bloodhound.specterops.io/resources/edges/overview
