# PCP Purity & Yield System — Formalized Rules

> Canonical reference for the purity/yield system design.
> Code must conform to these rules. Deviations must be documented as exceptions.

## Rule 1: Yield is a function of purity of stamped inputs

Lower input purity → fewer output items. Yield only applies to:
- **PROPAGATION and TERMINAL callbacks** (recipes that read stamped input purity)
- **Multi-output recipes** (output count ≥ 2)

Yield does NOT apply to SOURCE callbacks (random base purity, no stamped inputs).

## Rule 2: Purity does NOT affect yield on vanilla outputs

When the recipe output is a final vanilla product (e.g. `Base.DryFirestarterBlock`,
`Base.Matchbox`, `Base.BrainTan`), purity does not reduce yield. The PCP pipeline
hands off to the game world at full quantity.

### Documented Exceptions

| Recipe | Output | Reason |
|--------|--------|--------|
| `PCPMixBlackpowder` | `Base.GunPowder` (×10) | Flagship recipe. Blackpowder quality is the core gameplay loop. |

## Rule 3: Applied Chemistry skill — multiplicative sliding scale

Skill influence on purity is **multiplicative**, not additive:

```
skillMultiplier = 1.0 + (level / 10.0) * maxEffect
```

| Setting | maxEffect | Level 0 | Level 5 | Level 10 |
|---------|-----------|---------|---------|----------|
| None | 0.00 | ×1.00 | ×1.00 | ×1.00 |
| Low | 0.22 | ×1.00 | ×1.11 | ×1.22 |
| Standard | 0.44 | ×1.00 | ×1.22 | ×1.44 |
| High | 0.66 | ×1.00 | ×1.33 | ×1.66 |

Default sandbox setting: **Standard** (maxEffect = 0.44).

## Rule 4: Default beginning purity is 50%

The fallback purity for items without tracking or when no stamped inputs exist.
Source recipes use equipment-specific ranges (e.g. Mortar 30-50, Chemistry Set 50-70).

## Variance: ±15% multiplicative

Applied at the end of every purity calculation:

```
varianceRoll = ZombRand(31) - 15        -- integer in [-15, +15]
varianceMult = 1.0 + varianceRoll / 100 -- range [0.85, 1.15]
result       = base * varianceMult
```

This models real-world chemistry variance. Even a skilled chemist with good
equipment can get unlucky (or lucky).

## Complete Purity Formula

```
Phase 1 — Equipment:
  adjustedFactor = adjustFactorBySeverity(equipFactor, severity)
  baseOutput     = inputPurity * adjustedFactor

Phase 2 — Skill:
  skillMult  = 1.0 + (level / 10.0) * maxEffect
  postSkill  = baseOutput * skillMult

Phase 3 — Variance:
  varianceMult = 1.0 + random(-15, +15) / 100
  final        = postSkill * varianceMult

result = clamp(floor(final + 0.5), 0, 99)
```

## Yield Formula

```
yieldMult = lookupYieldTier(purity) * sandboxYieldMultiplier
keepCount = max(1, floor(baseCount * yieldMult + 0.5))
removeCount = baseCount - keepCount
```

Yield tiers:

| Purity | Tier | Yield Multiplier |
|--------|------|-----------------|
| 80-99 | Lab-Grade | 1.00 |
| 60-79 | Pure | 0.90 |
| 40-59 | Standard | 0.80 |
| 20-39 | Impure | 0.60 |
| 0-19 | Contaminated | 0.40 |

## Callback Categories

| Category | Purity Source | Yield? | Example |
|----------|--------------|--------|---------|
| SOURCE | Random base range | No | `pcpCrushCharcoalPurity` |
| PROPAGATION | Averaged stamped inputs × factor | Yes (if count ≥ 2) | `pcpPurifyCharcoalPurity` |
| TERMINAL | Propagation + explicit yield | Yes | `pcpCrystallizeSaltPurity` |
| HAZARD WRAPPER | Delegates to base callback | Inherited | `pcpExtractSulphurSafePurity` |
| VANILLA OUTPUT | No purity stamp | No (Rule 2) | `pcpMakeFireStarterYield` |
