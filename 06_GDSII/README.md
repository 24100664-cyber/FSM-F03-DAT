# F03 Lock — GDSII Physical Design

## 1. Design

- Design: `f03_lock_scaffold_explicit`
- Technology: SkyWater SKY130A
- Standard-cell library: `sky130_fd_sc_hd`
- Clock period: 10 ns
- Flow: RTL → Simulation → Synthesis → STA → Floorplan → Placement → CTS → Routing → Signoff → GDSII

## 2. Final Physical Design Results

| Metric | Result |
|---|---:|
| Total instances | 373 |
| Instance area | 2781.42 µm² |
| Standard-cell area | 1393.84 µm² |
| Die area | 4930.25 µm² |
| Die size | 65.06 × 75.78 µm |
| Core area | 2781.42 µm² |
| Routing wirelength | 2303 µm |
| Setup worst slack | 7.8702 ns |
| Hold worst slack | 0.4610 ns |
| Total power | 0.263 mW |

## 3. Signoff

| Check | Result |
|---|---|
| Routing DRC | PASS — 0 errors |
| Magic DRC | PASS — 0 errors |
| KLayout DRC | PASS — 0 errors |
| Antenna | PASS — 0 violating nets/pins |
| LVS | PASS — 0 device/net/property differences |
| Unmatched devices | 0 |
| Unmatched nets | 0 |
| Unmatched pins | 0 |

## 4. GDSII

Main GDSII:

`gds/f03_lock_scaffold_explicit.gds`

KLayout GDS:

`gds/f03_lock_scaffold_explicit.klayout.gds`

Layout preview:

`f03_lock_scaffold_explicit.png`

## 5. Reports

- `metrics.csv` — final LibreLane metrics
- `metrics.json` — machine-readable metrics
- `drc/drc.magic.rpt` — Magic DRC report
- `drc/drc.klayout.json` — KLayout DRC report
- `lvs/lvs.netgen.rpt` — Netgen LVS report
- `lvs/lvs.netgen.json` — machine-readable LVS result
- `antenna_summary.rpt` — antenna check summary

## 6. Flow Status

The LibreLane physical-design flow completed successfully.

Final signoff status:

- DRC: PASS
- LVS: PASS
- Antenna: PASS
- Setup violations: none
- Hold violations: none

The final GDSII layout is generated under `gds/`.
