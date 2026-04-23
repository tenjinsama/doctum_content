## Native Python Queue vs Multiprocessing Queue

**`queue.Queue`** is for **threading** (within same process), while **`multiprocessing.Queue`** is for **inter-process communication** (between separate processes). They serve different concurrency models.

* * *

## Side-by-Side Comparison

| Aspect | queue.Queue | multiprocessing.Queue |
| --- | --- | --- |
| **Use Case** | Multiple threads in same process | Multiple processes (separate interpreters) |
| **Memory** | Shared memory (all threads access same objects) | Separate memory (each process has own memory) |
| **Serialization** | Not needed (direct object references) | Required (pickle/serialize objects) |
| **Performance** | Faster (no serialization overhead) | Slower (serialization + IPC overhead) |
| **Thread Safety** | Yes (designed for threading) | Yes (designed for inter-process) |
| **GIL Impact** | Limited by Python's Global Interpreter Lock | No GIL limitation (separate processes) |
| **Pickling** | Not applicable | Objects must be picklable |
| **Import** | `from queue import Queue` | `from multiprocessing import Queue` |

* * *

## Concurrency Models

### Threading Model (Native Queue)

```python
from queue import Queue
import threading

# Shared memory space
shared_queue = Queue(maxsize=10)

def producer():
    for i in range(100):
        shared_queue.put(i)  # Share data directly

def consumer():
    while True:
        item = shared_queue.get()
        print(f"Consumed: {item}")

# All threads share same process and memory
t1 = threading.Thread(target=producer)
t2 = threading.Thread(target=consumer)
t1.start()
t2.start()
```

**How it works:**

- Single Python process with multiple threads
- All threads access same memory
- Objects passed by reference (no copying)
- Limited by Global Interpreter Lock (GIL)

### Multiprocessing Model (Multiprocessing Queue)

```python
from multiprocessing import Queue, Process

# Separate memory spaces
shared_queue = Queue(maxsize=10)

def producer():
    for i in range(100):
        shared_queue.put(i)  # Serialized and sent

def consumer():
    while True:
        item = shared_queue.get()
        print(f"Consumed: {item}")

# Separate processes with separate Python interpreters
p1 = Process(target=producer)
p2 = Process(target=consumer)
p1.start()
p2.start()
```

**How it works:**

- Multiple separate Python processes
- Each process has own memory space
- Objects must be pickled (serialized) to cross process boundaries
- No GIL limitation (true parallelism)

* * *

## Practical Examples

### Example 1: Serialization Requirement

**Native Queue (no serialization needed):**

```python
from queue import Queue
import threading

queue = Queue()

class CustomObject:
    def __init__(self, value):
        self.value = value

def producer():
    obj = CustomObject(42)
    queue.put(obj)  # ✅ Works fine - direct reference

def consumer():
    obj = queue.get()
    print(obj.value)  # ✅ Works

t1 = threading.Thread(target=producer)
t2 = threading.Thread(target=consumer)
t1.start()
t2.start()
t1.join()
t2.join()
```

**Multiprocessing Queue (requires serialization):**

```python
from multiprocessing import Queue, Process
import pickle

queue = Queue()

class CustomObject:
    def __init__(self, value):
        self.value = value

def producer():
    obj = CustomObject(42)
    queue.put(obj)  # ❌ Works only if CustomObject is picklable

def consumer():
    obj = queue.get()
    print(obj.value)  # ✅ Works (if pickling succeeds)

p1 = Process(target=producer)
p2 = Process(target=consumer)
p1.start()
p2.start()
p1.join()
p2.join()
```

**Pickling Issue:**

```python
from multiprocessing import Queue, Process

queue = Queue()

class UnpicklableObject:
    def __init__(self):
        self.lock = threading.Lock()  # Locks can't be pickled

def producer():
    obj = UnpicklableObject()
    queue.put(obj)  # ❌ PicklingError!
```

* * *

### Example 2: Performance Difference

```python
import time
from queue import Queue
import threading
from multiprocessing import Queue as MPQueue, Process

# Benchmark with threading
def thread_benchmark():
    queue = Queue()
    
    def producer():
        for i in range(10000):
            queue.put(i)
    
    def consumer():
        count = 0
        while count < 10000:
            queue.get()
            count += 1
    
    start = time.time()
    t1 = threading.Thread(target=producer)
    t2 = threading.Thread(target=consumer)
    t1.start()
    t2.start()
    t1.join()
    t2.join()
    print(f"Threading: {time.time() - start:.4f}s")

# Benchmark with multiprocessing
def mp_benchmark():
    queue = MPQueue()
    
    def producer():
        for i in range(10000):
            queue.put(i)
    
    def consumer():
        count = 0
        while count < 10000:
            queue.get()
            count += 1
    
    start = time.time()
    p1 = Process(target=producer)
    p2 = Process(target=consumer)
    p1.start()
    p2.start()
    p1.join()
    p2.join()
    print(f"Multiprocessing: {time.time() - start:.4f}s")

thread_benchmark()  # Faster (no serialization)
mp_benchmark()      # Slower (serialization overhead)
```

**Typical Output:**

```
Threading: 0.0234s
Multiprocessing: 1.2341s
```

* * *

### Example 3: GIL Impact

```python
import time
from queue import Queue
import threading
from multiprocessing import Queue as MPQueue, Process

def cpu_intensive_task(n):
    """CPU-bound work"""
    total = 0
    for i in range(n):
        total += i ** 2
    return total

# Threading with CPU-bound work (limited by GIL)
def thread_cpu_bound():
    queue = Queue()
    
    def worker():
        for _ in range(5):
            result = cpu_intensive_task(10000000)
            queue.put(result)
    
    start = time.time()
    threads = [threading.Thread(target=worker) for _ in range(4)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    print(f"Threading (CPU-bound): {time.time() - start:.4f}s")

# Multiprocessing with CPU-bound work (no GIL)
def mp_cpu_bound():
    queue = MPQueue()
    
    def worker():
        for _ in range(5):
            result = cpu_intensive_task(10000000)
            queue.put(result)
    
    start = time.time()
    processes = [Process(target=worker) for _ in range(4)]
    for p in processes:
        p.start()
    for p in processes:
        p.join()
    print(f"Multiprocessing (CPU-bound): {time.time() - start:.4f}s")

thread_cpu_bound()  # Slower (GIL limits parallelism)
mp_cpu_bound()      # Faster (true parallel execution)
```

* * *

## When to Use Each

### Use `queue.Queue` (Threading)

```python
from queue import Queue
import threading

# ✅ I/O-bound work: network requests, file reading, database queries
queue = Queue()

def fetch_data():
    for url in urls:
        response = requests.get(url)  # I/O wait (GIL released)
        queue.put(response)

# Threading is efficient for I/O because threads release GIL during I/O waits
threads = [threading.Thread(target=fetch_data) for _ in range(10)]
```

**Advantages:**

- Lightweight (low overhead)
- Shared memory simplifies data passing
- Good for I/O-bound tasks
- Fast context switching

### Use `multiprocessing.Queue` (Processes)

```python
from multiprocessing import Queue, Process

# ✅ CPU-bound work: data processing, mathematical computations, image manipulation
queue = Queue()

def process_data():
    for item in items:
        result = expensive_computation(item)
        queue.put(result)

# Multiprocessing avoids GIL for true CPU parallelism
processes = [Process(target=process_data) for _ in range(4)]
```

**Advantages:**

- True parallelism (no GIL limitation)
- Good for CPU-bound tasks
- Scales to multiple cores
- Isolated memory prevents race conditions

* * *

## Summary Table

| Scenario | Queue | Multiprocessing.Queue |
| --- | --- | --- |
| **I/O-bound (network, files, DB)** | ✅ Recommended | ⚠️ Overkill |
| **CPU-bound (heavy computation)** | ❌ GIL limited | ✅ Recommended |
| **Shared mutable state** | ✅ Easy | ⚠️ Complex |
| **Small data objects** | ✅ Fast | ⚠️ Serialization overhead |
| **Large data objects** | ⚠️ Memory intensive | ✅ Separate memory spaces |
| **Simple implementation** | ✅ Yes | ⚠️ More complex |

**General rule:**

- **Threading + `queue.Queue`** for **I/O-bound** tasks
- **Multiprocessing + `multiprocessing.Queue`** for **CPU-bound** tasks