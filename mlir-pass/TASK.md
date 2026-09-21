# MLIR (the JD skill)

Real dialects: `linalg`, `arith`, `affine`, `func`. This is not `toy-ir`.

## Done

```bash
make -C mlir-pass fuse
make -C mlir-pass tile
```

**Fusion:** two `linalg.generic` ops become **one** generic (`addf` then `mulf`). One loop, one write.

**Tiling:** `affine.for` 0..128 becomes an outer step-32 loop and an inner 32-trip loop.

## Why this is on the JD

You can say: I ran an MLIR rewrite on linalg (fusion) and affine (tiling). Op + pattern + before/after IR.

## Recode

No editor. Draw fuse **or** tile: IR before, the match, IR after, one input you would reject.
