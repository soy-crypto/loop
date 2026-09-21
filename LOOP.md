# Loop plan — compilers-background candidate

You already took compilers. SSA, DCE, CSE, CFG are assumed.
This plan does **not** reteach the course. It turns that into
**interview production**: C++ under time, a pass you wrote, a GPU number.

You write all code. I review and quiz. Do not open `prep/reference/`
until that step’s tests pass. Clock: 4–6h per step-day.

**Loop-ready** when you can do A–D with notes shut:

- **A** Recode toy DCE+CSE; say why backward liveness and why CSE remaps first
- **B** 45 min C++ (ownership, UB, STL) that compiles
- **C** Draw *your* MLIR fusion or tile: IR before / after
- **D** One kernel: naive vs better, one number, one sentence why

---

## How to use this

Do the steps **in order**. Do not skip a Done check.
After each step, message me with the artifact named in **Send**.
If a step fails, repeat it before continuing.

---

## Phase 0 — rules (10 min)

1. Read `toy-ir/TASK.md` only. Not `reference/`.
2. Implementations in `toy-ir` were wiped on purpose. You rebuild them.
3. Daily: 45 min C++ *in addition* to the step (leetcode-style or a small C++17 IR helper). Log misses in `misses.txt`.

**Send:** “phase 0 done.”

---

## Phase 1 — prove the course in code (2–3 days)

The course is real only if it comes out of your fingers.

### Step 1 — IR + dump

Write `toy-ir/ir.h`, `dump.cpp`, `main.cpp` per `TASK.md`.

**Done:** `make -C toy-ir run` prints *exactly* the `relu_mac` dump in `TASK.md`.

**Send:** the dump output.

### Step 2 — DCE

Write `dce.h` / `dce.cpp`. `store`/`return` are live roots. Walk **backwards**.

**Done:** `make -C toy-ir test_dce && ./toy-ir/test_dce`

**Send:** “DCE tests passed” plus, in chat, no notes: *why backward, not forward.*

### Step 3 — CSE const

Write `cse.h` / `cse.cpp`. Keep first const per immediate; remap uses.

**Done:** `make -C toy-ir test` (both tests).

**Send:** “CSE tests passed” plus, in chat: *why rewrite operands before deleting.*

### Step 4 — cold recode (the actual interview)

Delete `dce.cpp` and `cse.cpp` only. Recode both in one sitting. No `reference/`, no chat paste-back of old code.

**Done:** `make -C toy-ir test` again.

**Send:** “cold recode passed.”

### Step 5 — LLVM IR aloud

Open `llvm-drills/*.ll`. For `sum.ll`, `add.ll`, `abs_O0.ll`, `pick.ll`, `sum_ssa.ll`: say what each instruction does (you can talk to me).

**Done:** I quiz 5 random insts and you don’t freeze.

**Send:** “ready for IR quiz” — then I quiz.

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

## Phase 3 — one MLIR pass you can defend (4–5 days)

Course compilers are usually LLVM-ish or academic IR. NVIDIA will expect **MLIR vocabulary** (op, dialect, rewrite, lowering).

`mlir-opt` is already at `~/llvm-project/build/bin/mlir-opt`.

### Step 9 — toy tutorial, *only* enough to write a pass

Do the official Toy tutorial through: dialect + one transformation. Stop. Do not finish every chapter.

**Done:** you can define: op, region, rewrite pattern, conversion.

**Send:** four one-liners, those four words.

### Step 10 — fusion *or* tiling (pick one)

Write **your** pass with tests (days 8–11 of the old plan). Prefer fusion if you want “AI compiler” flavor (elementwise chain → one op). Prefer tiling if you want locality talk.

**Done:** `mlir-opt` (or your test binary) shows IR before and after.

**Send:** before/after IR (short) + pass name.

### Step 11 — draw it cold

No editor. Draw the IR, the match, the rewrite, one illegal input you’d reject.

**Done:** I say pass.

**Send:** “ready for pass mock.”

### Step 12 — recode the pass (or toy DCE if MLIR isn’t solid)

Same rule as step 4.

**Done:** tests pass from a blank file.

**Send:** “pass recode passed.”

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

**Step 1.** `toy-ir` dump. Do not wait for a better plan.
