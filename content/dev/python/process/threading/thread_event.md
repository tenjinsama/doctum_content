## `threading.Event()`

A `threading.Event` is a simple **communication tool between threads** — it allows one thread to signal something to other threads.

* * *

## The core idea

Think of it like a **traffic light**:

- 🔴 **Not set** → threads wait
- 🟢 **Set** → threads can go

```python
import threading

event = threading.Event()

print(event.is_set())  # False — red light by default
event.set()
print(event.is_set())  # True — green light
event.clear()
print(event.is_set())  # False — back to red
```

* * *

## The 4 key methods

| Method | What it does |
| --- | --- |
| `event.set()` | 🟢 Turns the light green — signals all waiting threads |
| `event.clear()` | 🔴 Turns the light red again |
| `event.is_set()` | Checks if the light is green (`True`/`False`) |
| `event.wait()` | **Blocks** the thread until the light turns green |

* * *

## A concrete example

```python
import threading
import time

event = threading.Event()

def worker():
    print("Worker: waiting for signal...")
    event.wait()          # ⏸ blocks here until event.set() is called
    print("Worker: got the signal, starting work!")

t = threading.Thread(target=worker)
t.start()

time.sleep(2)             # main thread does something else
print("Main: sending signal!")
event.set()               # 🟢 unblocks the worker thread
```

```
Worker: waiting for signal...
# (2 seconds pass)
Main: sending signal!
Worker: got the signal, starting work!
```

* * *

## Most common use case: stopping a thread gracefully

The most typical pattern you'll see in real code is using an event as a **stop signal**:

```python
import threading
import time

stop_event = threading.Event()

def worker():
    while not stop_event.is_set():  # keep running until told to stop
        print("Working...")
        time.sleep(1)
    print("Worker stopped cleanly.")

t = threading.Thread(target=worker)
t.start()

time.sleep(3)
stop_event.set()   # politely tells the thread to stop
```

```
Working...
Working...
Working...
Worker stopped cleanly.
```

This is much safer than **killing** a thread forcefully — the thread finishes its current task, then stops on its own.

* * *

## In short

> `threading.Event()` is a **flag that threads can watch** — one thread raises it, others react to it. It's the simplest way to coordinate or stop threads safely.