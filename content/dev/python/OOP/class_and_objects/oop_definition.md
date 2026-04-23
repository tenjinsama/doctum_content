## Object-Oriented Programming in Python

### The Core Idea

OOP is a way of modeling your program around **things** (objects) rather than procedures. Each thing has:
- **Attributes** — what it *is* (data/state)
- **Methods** — what it *does* (behavior)

A **class** is the *blueprint*. An **object** is a *concrete instance* built from that blueprint.

---

### 1. Class & Object — The Basics

```python
class Dog:
    # Class attribute — shared by ALL instances
    species = "Canis familiaris"

    # Constructor — runs when an object is created
    def __init__(self, name, age):
        # Instance attributes — unique to each object
        self.name = name
        self.age = age

    # Instance method
    def bark(self):
        return f"{self.name} says: Woof!"

# Creating objects (instances)
dog1 = Dog("Rex", 3)
dog2 = Dog("Bella", 5)

print(dog1.name)       # Rex
print(dog2.bark())     # Bella says: Woof!
print(dog1.species)    # Canis familiaris
```

`self` refers to the current instance — it's how a method knows *which* object it's operating on.

---

### 2. The Four Pillars of OOP

---

#### Encapsulation — hiding internal details

Bundle data and methods together, and restrict direct access to internals using naming conventions.

```python
class BankAccount:
    def __init__(self, balance):
        self.__balance = balance  # __ makes it "private"

    def deposit(self, amount):
        if amount > 0:
            self.__balance += amount

    def get_balance(self):
        return self.__balance

account = BankAccount(1000)
account.deposit(500)
print(account.get_balance())   # 1500
# print(account.__balance)     # ❌ AttributeError — private!
```

| Convention | Meaning |
|---|---|
| `name` | Public — accessible anywhere |
| `_name` | Protected — "please don't touch" (convention only) |
| `__name` | Private — name-mangled by Python, harder to access |

---

#### Inheritance — reusing and extending classes

A child class **inherits** attributes and methods from a parent, and can add or override them.

```python
class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):
        return "Some sound"

class Cat(Animal):           # Cat inherits from Animal
    def speak(self):         # Override parent method
        return f"{self.name} says: Meow!"

class Dog(Animal):
    def speak(self):
        return f"{self.name} says: Woof!"

animals = [Cat("Whiskers"), Dog("Rex")]
for animal in animals:
    print(animal.speak())
# Whiskers says: Meow!
# Rex says: Woof!
```

`super()` lets you call the parent class's method:

```python
class GuideDog(Dog):
    def __init__(self, name, owner):
        super().__init__(name)   # call Dog's __init__
        self.owner = owner

    def speak(self):
        base = super().speak()   # call Dog's speak()
        return f"{base} (Guide dog for {self.owner})"
```

---

#### Polymorphism — same interface, different behavior

Different classes can be used interchangeably if they share the same method names — the right one gets called automatically.

```python
class Circle:
    def __init__(self, radius):
        self.radius = radius
    def area(self):
        return 3.14 * self.radius ** 2

class Rectangle:
    def __init__(self, w, h):
        self.w, self.h = w, h
    def area(self):
        return self.w * self.h

shapes = [Circle(5), Rectangle(4, 6)]
for shape in shapes:
    print(shape.area())   # Each calls its OWN area()
# 78.5
# 24
```

The caller doesn't need to know or care what *type* of shape it has — it just calls `.area()`.

---

#### Abstraction — defining contracts, hiding complexity

Use abstract classes to define a *required interface* without implementing it — forcing subclasses to fill in the details.

```python
from abc import ABC, abstractmethod

class Shape(ABC):          # Abstract base class
    @abstractmethod
    def area(self):        # Subclasses MUST implement this
        pass

    @abstractmethod
    def perimeter(self):
        pass

class Square(Shape):
    def __init__(self, side):
        self.side = side

    def area(self):
        return self.side ** 2

    def perimeter(self):
        return 4 * self.side

# Shape()    # ❌ TypeError — can't instantiate abstract class
s = Square(4)
print(s.area())       # 16
print(s.perimeter())  # 16
```

---

### 3. Special (Dunder) Methods

Python lets you customize how objects behave with built-in operations by defining `__dunder__` methods.

```python
class Vector:
    def __init__(self, x, y):
        self.x, self.y = x, y

    def __str__(self):              # print(v) → readable string
        return f"Vector({self.x}, {self.y})"

    def __repr__(self):             # developer representation
        return f"Vector(x={self.x}, y={self.y})"

    def __add__(self, other):       # v1 + v2
        return Vector(self.x + other.x, self.y + other.y)

    def __len__(self):              # len(v)
        return int((self.x**2 + self.y**2) ** 0.5)

v1 = Vector(2, 3)
v2 = Vector(1, 4)
print(v1)           # Vector(2, 3)
print(v1 + v2)      # Vector(3, 7)
print(len(v1))      # 3
```

---

### 4. Class vs Static Methods

```python
class Counter:
    count = 0

    def __init__(self):
        Counter.count += 1
        self.id = Counter.count

    @classmethod
    def get_count(cls):        # receives the CLASS, not an instance
        return cls.count

    @staticmethod
    def description():         # receives NOTHING — just a utility
        return "I count instances"

c1 = Counter()
c2 = Counter()
print(Counter.get_count())     # 2
print(Counter.description())   # I count instances
```

| Type | Decorator | First arg | Use case |
|---|---|---|---|
| Instance method | *(none)* | `self` | Works with instance data |
| Class method | `@classmethod` | `cls` | Works with class-level data |
| Static method | `@staticmethod` | *(none)* | Utility, no access to instance or class |

---

### Big Picture

```
Class (Blueprint)
 ├── Attributes (data)
 ├── Methods (behavior)
 └── Special methods (__init__, __str__, ...)

Object (Instance)
 ├── Has its own attribute values
 └── Shares methods from the class

Pillars
 ├── Encapsulation  → protect internal state
 ├── Inheritance    → reuse and extend
 ├── Polymorphism   → same interface, different behavior
 └── Abstraction    → define contracts, hide complexity
```

OOP shines when modeling real-world entities, building large codebases, or designing extensible systems where new types need to slot in without changing existing code.