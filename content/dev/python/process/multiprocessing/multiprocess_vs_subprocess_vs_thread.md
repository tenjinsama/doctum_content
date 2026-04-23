## subprocess vs multiprocessing vs threading

These solve different problems. The key is understanding **what you're trying to parallelize**.

* * *

## The core distinction

```
threading        → multiple threads, ONE Python process, shared memory
                   blocked by the GIL for CPU work

multiprocessing  → multiple Python processes, SEPARATE memory
                   bypasses the GIL, true parallelism for CPU work

subprocess       → launches a completely external program (bash, ffmpeg, git...)
                   not Python-to-Python communication
```

* * *

## Threading — concurrent I/O in one process

Python has a **GIL (Global Interpreter Lock)** — only one thread runs Python bytecode at a time. But threads are released during I/O waits, making threading useful for I/O-bound tasks:

```python
import threading
import requests

results = []
lock = threading.Lock()

def fetch(url):
    response = requests.get(url)          # GIL released during network wait
    with lock:                            # protect shared state
        results.append(response.status_code)

urls = ["https://example.com"] * 5

threads = [threading.Thread(target=fetch, args=(url,)) for url in urls]

for t in threads: t.start()
for t in threads: t.join()               # wait for all to finish

print(results)  # [200, 200, 200, 200, 200]
```

```python
# GIL means this WON'T actually run in parallel — no speedup
def cpu_heavy(n):
    return sum(i * i for i in range(n))  # pure Python CPU work

# threads take turns, not simultaneous → pointless for this
```

✅ Use for: API calls, file reads, DB queries, anything waiting on I/O ❌ Avoid for: CPU-heavy computation (sorting, math, image processing)

* * *

## Multiprocessing — true parallelism for CPU work

Each process gets its own Python interpreter and memory — no GIL limitation:

```python
from multiprocessing import Pool
import os

def cpu_heavy(n):
    print(f"Process {os.getpid()} working")
    return sum(i * i for i in range(n))

if __name__ == "__main__":              # required guard on Windows/macOS
    with Pool(processes=4) as pool:     # 4 separate Python processes
        results = pool.map(cpu_heavy, [10_000_000] * 4)

    print(results)
```

Processes have **separate memory** — sharing data requires explicit mechanisms:

```python
from multiprocessing import Process, Queue

def worker(q, n):
    q.put(n * n)            # send result back via Queue

if __name__ == "__main__":
    q = Queue()
    processes = [Process(target=worker, args=(q, i)) for i in range(5)]

    for p in processes: p.start()
    for p in processes: p.join()

    results = [q.get() for _ in processes]
    print(results)          # [0, 1, 4, 9, 16] in some order
```

✅ Use for: data crunching, ML preprocessing, image processing, simulations ❌ Avoid for: lots of shared state (copying memory between processes is expensive)

* * *

## Subprocess — running external programs

Completely different purpose — launching **other programs**, not Python functions:

```python
import subprocess

# Run a command, capture output
result = subprocess.run(
    ["git", "log", "--oneline", "-5"],
    capture_output=True,
    text=True
)
print(result.stdout)
print(result.returncode)   # 0 = success
```

```python
# Pipeline — chain commands like bash pipes
ps = subprocess.Popen(["ps", "aux"], stdout=subprocess.PIPE)
grep = subprocess.Popen(["grep", "python"],
                         stdin=ps.stdout,
                         stdout=subprocess.PIPE,
                         text=True)
ps.stdout.close()
output, _ = grep.communicate()
print(output)
```

```python
# Check=True raises exception on failure
try:
    subprocess.run(["ffmpeg", "-i", "input.mp4", "output.gif"],
                   check=True,
                   capture_output=True)
except subprocess.CalledProcessError as e:
    print(f"ffmpeg failed: {e.stderr}")
```

✅ Use for: shell commands, git, ffmpeg, compilers, any non-Python tool ❌ Avoid for: running your own Python functions (use the others instead)

* * *

## Side by side comparison

```python
# SAME GOAL — process 4 files — three different tools

# subprocess: delegates to an external CLI tool
for f in files:
    subprocess.run(["convert", f, f.replace(".png", ".jpg")])

# threading: your Python code, I/O bound (reading/writing files)
with ThreadPoolExecutor(max_workers=4) as ex:
    ex.map(convert_image_io, files)

# multiprocessing: your Python code, CPU bound (heavy pixel math)
with Pool(4) as pool:
    pool.map(convert_image_cpu, files)
```

* * *

## Decision flowchart

```
What are you trying to do?
│
├── Run an external program (git, ffmpeg, bash)?
│   └── subprocess
│
├── Run your own Python code?
│   │
│   ├── Waiting on I/O (network, files, DB)?
│   │   └── threading  (or asyncio for very high concurrency)
│   │
│   └── Heavy CPU computation (math, parsing, ML)?
│       └── multiprocessing
```

* * *

## Quick reference

|     | threading | multiprocessing | subprocess |
| --- | --- | --- | --- |
| GIL affected | ✅ yes | ❌ bypassed | ❌ n/a |
| Shared memory | ✅ yes | ❌ separate | ❌ separate |
| Best for | I/O bound | CPU bound | external programs |
| Overhead | low | high (process spawn) | medium |
| Communication | shared vars + locks | Queue, Pipe, Value | stdin/stdout/stderr |
| Crash isolation | ❌ crashes whole app | ✅ isolated per process | ✅ isolated |

For very high I/O concurrency (thousands of connections), also consider **`asyncio`** — it handles concurrency in a single thread using an event loop, with even less overhead than threading.