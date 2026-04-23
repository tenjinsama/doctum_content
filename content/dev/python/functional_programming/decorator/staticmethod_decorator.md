## `@staticmethod` vs `@classmethod`

* * *

## What is a `@staticmethod`?

A static method is a method that **receives nothing automatically** — no `self`, no `cls`. It's just a regular function that lives inside a class for organizational purposes.

```python
class MathHelper:
    @staticmethod
    def add(a, b):
        return a + b  # no self, no cls — just pure logic

MathHelper.add(3, 5)  # ✅ 8
```

* * *

## Side by side comparison

```python
class MyClass:
    class_variable = "I am the class"

    def regular_method(self):
        return self  # receives the INSTANCE

    @classmethod
    def class_method(cls):
        return cls  # receives the CLASS

    @staticmethod
    def static_method():
        return "I receive nothing"  # receives NOTHING
```

|     | Regular method | `@classmethod` | `@staticmethod` |
| --- | --- | --- | --- |
| Auto first arg | `self` (instance) | `cls` (class) | nothing |
| Access instance state | ✅   | ❌   | ❌   |
| Access class state | ✅   | ✅   | ❌   |
| Can be inherited smartly | ✅   | ✅   | ✅ (but dumb) |
| Needs an instance to call | ✅   | ❌   | ❌   |

* * *

## The key difference with `@classmethod`

The only difference is what they **receive automatically**:

```python
class Dog:
    species = "Canis familiaris"

    @classmethod
    def get_species_class(cls):
        return cls.species  # cls = Dog, can access class variables

    @staticmethod
    def get_species_static():
        return Dog.species  # must hardcode the class name
```

This matters with **inheritance**:

```python
class Poodle(Dog):
    species = "Poodle variant"

# classmethod is inheritance-aware — cls = Poodle
Poodle.get_species_class()   # ✅ "Poodle variant"

# staticmethod is NOT — Dog is hardcoded
Poodle.get_species_static()  # ❌ "Canis familiaris" (wrong class)
```

* * *

## So which one to use?

> **Ask yourself:** does the method need to know about the class or any instance?

- **Yes, needs the instance** → regular method
- **Yes, needs the class** (or will be inherited) → `@classmethod`
- **No, it's just pure logic** → `@staticmethod`

* * *

## Back to `_clear_queue`

```python
@classmethod
def _clear_queue(cls, q: queue.Queue):
    try:
        while True:
            q.get_nowait()
    except queue.Empty:
        pass
```

Since `cls` is **never used** in the body, a `@staticmethod` would technically be **more accurate** here:

```python
@staticmethod
def _clear_queue(q: queue.Queue):  # more honest — needs nothing from the class
    try:
        while True:
            q.get_nowait()
    except queue.Empty:
        pass
```

The original developer likely used `@classmethod` out of habit or mild imprecision — it works fine either way.