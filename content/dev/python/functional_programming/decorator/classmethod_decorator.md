## Class Methods in Python

A `classmethod` is a method that receives the **class itself** (`cls`) as its first argument instead of an instance (`self`). It's defined with the `@classmethod` decorator.

```python
class MyClass:
    count = 0

    def __init__(self, name):
        self.name = name
        MyClass.count += 1

    @classmethod
    def get_count(cls):
        return cls.count  # accesses the class, not an instance
```

* * *

## When is it useful?

**1\. Alternative constructors** — the most common use case. When you want multiple ways to create an object:

```python
class Date:
    def __init__(self, year, month, day):
        self.year, self.month, self.day = year, month, day

    @classmethod
    def from_string(cls, date_str):          # "2024-01-15"
        year, month, day = map(int, date_str.split("-"))
        return cls(year, month, day)

    @classmethod
    def from_timestamp(cls, timestamp):      # 1705276800
        import datetime
        d = datetime.date.fromtimestamp(timestamp)
        return cls(d.year, d.month, d.day)

# Usage
d1 = Date(2024, 1, 15)
d2 = Date.from_string("2024-01-15")
d3 = Date.from_timestamp(1705276800)
```

**2\. Accessing or modifying class-level state:**

```python
class User:
    _registry = []

    def __init__(self, name):
        self.name = name
        User._registry.append(self)

    @classmethod
    def get_all_users(cls):
        return cls._registry

    @classmethod
    def clear_registry(cls):
        cls._registry = []
```

**3\. Inheritance-aware factory methods** — `cls` always refers to the class that called the method, so subclasses work correctly:

```python
class Animal:
    def __init__(self, name):
        self.name = name

    @classmethod
    def create(cls, name):
        return cls(name)  # returns a Dog if called on Dog, not Animal

class Dog(Animal):
    def speak(self):
        return "Woof!"

dog = Dog.create("Rex")  # returns a Dog instance, not Animal
```

* * *

## Quick comparison

|     | `self` method | `@classmethod` | `@staticmethod` |
| --- | --- | --- | --- |
| First arg | instance | class (`cls`) | nothing |
| Access instance state | ✅   | ❌   | ❌   |
| Access class state | ✅   | ✅   | ❌   |
| Inheritance-aware | ✅   | ✅   | ❌   |

**In short:** use `@classmethod` when the logic belongs to the class as a whole rather than to any specific instance — especially for alternative constructors.