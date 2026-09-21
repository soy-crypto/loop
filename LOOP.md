# Loop plan — compilers-background candidate

You already took compilers. SSA, DCE, CSE, CFG are assumed.
This plan does **not** reteach the course. It turns that into
**interview production**: C++ under time, a pass you wrote, a GPU number.

You write all code. I review and quiz. Do not open `prep/reference/`
until that step’s tests pass. Clock: 4–6h per step-day.

**Loop-ready** when you can do A–D with notes shut:

- **A** Recode toy DCE+CSE; say why backward liveness and why CSE remaps first
- **B** 45 min C++ (ownership, UB, STL) that compiles
- **C** LLVM DCE on real IR (`llvm-pass`) **and** draw MLIR fuse or tile (`mlir-pass`)
- **D** One kernel: naive vs better, one number, one sentence why

---

## How to use this

Do the steps **in order**. Do not skip a Done check.
After each step, message me with the artifact named in **Send**.
If a step fails, repeat it before continuing.

---

## Phase 0 — rules (10 min)

1. Read `toy-ir/STUDY.cpp`. Not `reference/`.
2. Daily: 45 min C++ (`cpp/`). Log misses in `misses.txt`.

**Send:** “phase 0 done.”

---

## Phase 1 — prove the course in code (2–3 days)

The course is real only if it comes out of your fingers.

### Step 1–3 — IR + DCE + CSE

Read and run `toy-ir/STUDY.cpp`.

**Done:** `make -C toy-ir study && ./toy-ir/study`

**Send:** “STUDY passed” plus, no notes: *why DCE is backward* and *why CSE remaps before delete.*

### Step 4 — cold recode

Delete the bodies of `dce` and `cse_const` in `STUDY.cpp`. Recode both in one sitting.

**Done:** `make -C toy-ir study && ./toy-ir/study` again.

**Send:** “cold recode passed.”

### Step 5 — real LLVM DCE

Last week was **reading** `.ll`. The JD wants **API**. `llvm-pass/` loads `llvm::Module` and deletes trivially dead insts.

**Done:** `make -C llvm-pass run` prints `removed 1` and `%dead` is gone.

**Send:** that IR snippet. Then recode `llvm-pass/dce.cpp` from empty.

### Step 6 — whiteboard DCE

I give you a small SSA fragment. You mark live/dead and rewrite the block. No laptop IR.

**Done:** I say pass.

**Send:** “ready for board DCE.”

---

## Phase 2 — C++ is the other half of the loop (overlap with phase 1, then 2–3 days hard)

Compilers course ≠ C++ interview.

### Step 7 — ownership

Write (no STL containers as a crutch for the *problem*): a tiny `Value` / `Use` or graph node with `unique_ptr` children, or a pass that deletes dead `Inst`s from a `vector` without iterator UB.

**Done:** compiles with `-Wall -Wextra`; you can say who owns each pointer.

**Send:** file path + 5-line ownership story.

### Step 8 — timed C++

90 minutes, one problem (I’ll assign when you hit this step): implement and talk.

**Done:** working code + you narrate as you go.

**Send:** when you want the prompt.

---

## Phase 3 — MLIR on the JD (1–2 days)

### Step 9–10 — run fuse and tile

```bash
make -C mlir-pass fuse
make -C mlir-pass tile
```

**Done:** you can point at the after-IR (one generic; step-32 loops).

**Send:** a short before/after (or “fuse+tile ran”).

### Step 11 — draw it cold

No editor. Fusion or tiling: IR before, match, after, one illegal input you’d reject.

**Done:** I say pass.

**Send:** “ready for pass mock.”

### Step 12 — skip unless the draw fails

Re-run `mlir-pass`, then retry step 11. Do not start the full Toy tutorial.

---

## Phase 4 — one GPU number (4–5 days)

AI compiler loop: *graphs in, fast GPU code out.* A course rarely grades this.

### Step 13 — GEMM schedule

TVM TIR or CUDA: default GEMM vs split/reorder/cache (or equivalent tiling).

**Done:** you can print or run both versions.

**Send:** what you changed (3 bullets).

### Step 14 — measure

Time both (or `ncu` if you have a GPU). Two-row table.

**Done:** one sentence: *which bottleneck moved* (not “it’s faster”).

**Send:** the table + the sentence.

### Step 15 — attention (optional if 14 is strong)

Naive vs tiled (or vs PyTorch). One more number.

**Done:** you can say why FlashAttention exists in one minute (IO, not “it’s a paper”).

**Send:** number + the one-minute script.

### Step 16 — 3-minute story

Out loud: problem → IR or schedule change → number.

**Done:** under 3:00, no slides.

**Send:** “ready for story drill.”

---

## Phase 5 — full mock (1 day)

### Step 17

I run: 45 min C++ + 45 min pass-on-board + 10 min story.

**Done:** I score you loop-ready or name the hole. Repeat only the failing phase.

**Send:** “book the mock.”

---

## Explicitly skip until after an onsite, or recruiter asks

- AutoTVM / MetaSchedule week
- FlashInfer skim
- “Apply NCG” (already done)
- Polished multi-project GitHub (push toy-ir + the one pass when they exist)

---

## Now

**Step 1.** `make -C toy-ir study && ./toy-ir/study`
