# F03 GDSII V2 vs V3 — XOR Comparison

## Result

**PASS — no geometric differences detected.**

The V2 and V3 GDSII layouts were compared directly using the
KLayout `pya` geometry API.

## Layout metadata

| Property | V2 | V3 |
|---|---|---|
| Top cell | `f03_lock_scaffold_explicit` | `f03_lock_scaffold_explicit` |
| Database unit (DBU) | 0.001 µm | 0.001 µm |
| Layer/datatype pairs | 40 | 40 |

## XOR summary

| Metric | Result |
|---|---:|
| Layer/datatype pairs checked | 40 |
| Layers with geometric differences | 0 |
| Total XOR polygons | 0 |
| XOR area on every checked layer | 0 µm² |

## Conclusion

The XOR comparison detected no geometric differences between V2 and V3
on the 40 checked layer/datatype pairs, including geometry expanded
recursively through child cells.

This establishes geometric equivalence within the scope of this XOR
comparison. It does not, by itself, establish identical file bytes,
RTL, electrical connectivity, or complete signoff provenance.

## Reproducibility

The comparison used the following files:

- `gds_v2_20261026/f03_lock_scaffold_explicit_v2.gds`
- `gds_v3_20261027/f03_lock_scaffold_explicit_v3.gds`

The files have different SHA-256 hashes; this is compatible with a zero
geometric XOR because byte-level file identity and geometric equivalence
are different checks.
