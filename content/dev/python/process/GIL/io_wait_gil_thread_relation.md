## I/O Waits, Threads, CPU and RAM

Let's build up from the hardware level.

* * *

## What is a CPU core actually doing?

A CPU core can only do **one thing at a time**. It executes instructions at billions per second — but it constantly needs data:

```
CPU core speed:       ~1 instruction per nanosecond
RAM access:           ~100 nanoseconds   (100x slower)
SSD read:             ~100 microseconds  (100,000x slower)
Network request:      ~100 milliseconds  (100,000,000x slower)
```

When the CPU asks for data from RAM, disk, or network — it has to **wait**. That waiting period is an **I/O wait**.

* * *

## What happens during an I/O wait

```
Without concurrency:

CPU:  [work]──[WAITING for network]──────────────────────[work]──[WAITING]──────
       doing nothing here, just idle ↑

With threading:

Thread 1:  [work]──[waiting...]─────────────────[resume]
Thread 2:          [work]──[waiting...]────[resume]
Thread 3:                  [work]──[waiting...]────[resume]
CPU:       [T1]────[T2]────[T3]────[T2]────[T1]────[T3]──  ← always busy
```

The CPU switches to another thread while one is waiting. No CPU time wasted.

* * *

## What is a Thread — at the hardware level

A **process** is a running program. It owns:

- its own block of **RAM** (code, heap, stack)
- its own file handles, network sockets
- isolated from other processes

A **thread** lives *inside* a process:

```
PROCESS (your Python script)
├── RAM
│   ├── Code segment      (shared by all threads — the .py bytecode)
│   ├── Heap              (shared by all threads — objects, variables)
│   └── Stack × N         (each thread gets its OWN call stack)
│       ├── Thread 1 stack  → its own local variables, function calls
│       ├── Thread 2 stack  → its own local variables, function calls
│       └── Thread 3 stack  → its own local variables, function calls
└── CPU registers (saved/restored per thread on each context switch)
```

So threads share **heap memory** but each has its own **execution stack**.

* * *

## What a stack vs heap means concretely

```python
# HEAP — shared between all threads
shared_list = []           # lives on the heap, all threads see it

def fetch(url):
    # STACK — private to this thread
    response = requests.get(url)   # local var, on this thread's stack
    text = response.text           # also local

    # writing to heap → DANGER, needs a lock
    shared_list.append(text)
```

```
Thread 1 stack          Thread 2 stack          HEAP (shared)
──────────────          ──────────────          ─────────────
fetch()                 fetch()                 shared_list = [...]
  url = "example.com"     url = "google.com"    my_object = ...
  response = ...          response = ...
  text = "..."            text = "..."
```

Two threads can read/write the heap simultaneously → **race conditions** if unprotected.

* * *

## What the CPU sees — context switching

The OS scheduler gives each thread a **time slice** (~1-10ms), then switches:

```
Time:     0ms      5ms      10ms     15ms     20ms
CPU:      [T1]─────[T2]─────[T3]─────[T1]─────[T2]───
           ↑        ↑        ↑
           save T1  save T2  save T3
           registers registers registers
           load T2  load T3  load T1
```

Each switch saves and restores the thread's **registers** (program counter, stack pointer etc). This is a **context switch** — it has a small cost.

* * *

## The Python GIL — why it exists

Python objects on the heap (lists, dicts, ints) have a **reference count**:

```python
x = [1, 2, 3]   # refcount = 1
y = x            # refcount = 2
del x            # refcount = 1
del y            # refcount = 0 → garbage collected
```

If two threads modify a refcount simultaneously without protection:

```
Thread 1 reads refcount:  5
Thread 2 reads refcount:  5
Thread 1 writes:          6   (5+1)
Thread 2 writes:          6   (5+1)  ← should be 7, memory corruption!
```

The **GIL is a single lock** that only lets one thread execute Python bytecode at a time — preventing this corruption. Simple solution, but means no true CPU parallelism with threads.

```
Without GIL (C++, Java):   T1 and T2 run Python simultaneously on 2 cores
With GIL (Python):         T1 runs, T2 waits → then T2 runs, T1 waits
```

* * *

## Why threads still help for I/O despite the GIL

```python
import requests

def fetch(url):
    # ↓ GIL is RELEASED here — thread says "I'm waiting for network,
    #   another thread can run Python now"
    response = requests.get(url)
    # ↑ GIL reacquired to process the response
    return response.status_code
```

C extensions like `requests`, file reads, DB drivers **release the GIL** during the actual wait. Python threads get real concurrency for anything that involves waiting.

* * *

## Full picture — threads vs processes vs async

```
PROCESS A (Python)                    PROCESS B (Python)
┌─────────────────────────┐           ┌──────────────────┐
│ Heap (shared)           │           │ Heap (separate)  │
│  - your objects         │           │  - own objects   │
│  - GIL                  │           │  - own GIL       │
│                         │           │                  │
│ Thread 1 ──[stack]      │           │ Thread 1 ──[stack]│
│ Thread 2 ──[stack]      │           └──────────────────┘
│ Thread 3 ──[stack]      │
└─────────────────────────┘
        ↑
   all share heap
   GIL = only one runs at a time
   but released during I/O
```

* * *

## Summary

| Concept | What it is |
| --- | --- |
| I/O wait | CPU idle time while waiting for network, disk, DB |
| Process | isolated program with its own RAM |
| Thread | lightweight execution unit inside a process, shares heap |
| Stack | per-thread memory for local variables and function calls |
| Heap | shared memory for objects, accessible by all threads |
| GIL | Python lock preventing true thread parallelism on CPU |
| Context switch | OS saving one thread's state and loading another's |

The one-line mental model:

- **Thread** = separate call stack, shared memory, one CPU token at a time (GIL)
- **Process** = fully separate program, own memory, own GIL, true parallelism
- **I/O wait** = the idle gap where switching to another thread costs nothing