## `super()` in Python

### What is it?

`super()` is a built-in function that gives you access to **methods from a parent (base) class**. It's most commonly used in inheritance to:
- Call the parent's `__init__` to avoid rewriting initialization logic
- Extend (not fully replace) a parent's method
- Navigate complex inheritance chains correctly

---

### 1. The Problem Without `super()`

```python
class Animal:
    def __init__(self, name, age):
        self.name = name
        self.age = age

class Dog(Animal):
    def __init__(self, name, age, breed):
        # ❌ Manually repeating parent logic — brittle and redundant
        self.name = name
        self.age = age
        self.breed = breed
```

If `Animal.__init__` ever changes, you'd have to update every child class manually. `super()` solves this.

---

### 2. Basic Usage — `__init__`

```python
class Animal:
    def __init__(self, name, age):
        self.name = name
        self.age = age
        print(f"Animal.__init__ called for {name}")

class Dog(Animal):
    def __init__(self, name, age, breed):
        super().__init__(name, age)   # ✅ delegate to parent
        self.breed = breed            # then add Dog-specific attr
        print(f"Dog.__init__ called, breed={breed}")

d = Dog("Rex", 3, "Labrador")
# Animal.__init__ called for Rex
# Dog.__init__ called, breed=Labrador

print(d.name)    # Rex    ← set by Animal.__init__
print(d.breed)   # Labrador ← set by Dog.__init__
```

`super().__init__()` runs the parent's constructor, so the child doesn't need to repeat that logic.

---

### 3. Extending a Parent Method

`super()` isn't just for `__init__` — use it any time you want to **run the parent's version AND add more behavior**, rather than fully replacing it.

```python
class Animal:
    def speak(self):
        return "Some generic sound"

    def describe(self):
        return f"I am {self.name}, age {self.age}"

class Dog(Animal):
    def speak(self):
        parent_sound = super().speak()        # get parent result
        return f"{parent_sound} ... Woof!"   # extend it

    def describe(self):
        base = super().describe()             # reuse parent logic
        return f"{base}, breed: {self.breed}"

d = Dog("Rex", 3, "Labrador")
print(d.speak())     # Some generic sound ... Woof!
print(d.describe())  # I am Rex, age 3, breed: Labrador
```

---

### 4. Multi-level Inheritance

`super()` chains correctly through multiple levels:

```python
class Animal:
    def __init__(self, name):
        self.name = name
        print("Animal init")

class Dog(Animal):
    def __init__(self, name, breed):
        super().__init__(name)       # calls Animal.__init__
        self.breed = breed
        print("Dog init")

class GuideDog(Dog):
    def __init__(self, name, breed, owner):
        super().__init__(name, breed)  # calls Dog.__init__
        self.owner = owner             # which in turn calls Animal.__init__
        print("GuideDog init")

g = GuideDog("Rex", "Labrador", "Alice")
# Animal init
# Dog init
# GuideDog init

print(g.name)    # Rex
print(g.breed)   # Labrador
print(g.owner)   # Alice
```

Each level calls its own parent — the chain flows naturally upward.

---

### 5. Multiple Inheritance & MRO

This is where `super()` really earns its place. When a class inherits from **multiple parents**, Python uses the **MRO (Method Resolution Order)** — a deterministic left-to-right, depth-first order — to decide which parent's method to call.

```python
class A:
    def hello(self):
        print("A.hello")

class B(A):
    def hello(self):
        print("B.hello")
        super().hello()

class C(A):
    def hello(self):
        print("C.hello")
        super().hello()

class D(B, C):       # inherits from both B and C
    def hello(self):
        print("D.hello")
        super().hello()

D().hello()
```

Output:
```
D.hello
B.hello
C.hello
A.hello
```

Python's MRO ensures `A.hello` is called **only once**, even though both `B` and `C` inherit from `A`. You can inspect the MRO:

```python
print(D.__mro__)
# (<class 'D'>, <class 'B'>, <class 'C'>, <class 'A'>, <class 'object'>)
```

Without `super()`, using `A.hello(self)` directly would break this chain and could call `A` multiple times or skip `C` entirely.

---

### 6. `super()` with `@property`

```python
class Animal:
    @property
    def info(self):
        return f"Name: {self.name}"

class Dog(Animal):
    @property
    def info(self):
        base = super().info          # access parent property
        return f"{base}, Breed: {self.breed}"

d = Dog("Rex", 3, "Labrador")
print(d.info)   # Name: Rex, Breed: Labrador
```

---

### Summary

| Use case | What `super()` does |
|---|---|
| `super().__init__()` | Runs parent constructor, avoids repeating code |
| `super().method()` | Extends a method instead of fully replacing it |
| Multi-level inheritance | Automatically chains up through all ancestors |
| Multiple inheritance | Follows MRO — ensures each class is called once |

The core principle: **`super()` means "delegate to the next class in the inheritance chain"** — it keeps your code DRY, and makes inheritance safe and predictable, especially when the hierarchy gets complex.