## Constructors, Getters & Setters in Python

### 2. Getters & Setters

In many OOP languages (Java, C#), getters and setters are explicit methods like `getName()` / `setName()`. Python has a more elegant approach.

---

#### The naive way — direct access (too open)

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

p = Person("Alice", 30)
p.age = -10    # ❌ No validation — bad data gets in!
```

---

#### The Java-style way — explicit get/set methods (too verbose)

```python
class Person:
    def __init__(self, name, age):
        self._age = age

    def get_age(self):
        return self._age

    def set_age(self, value):
        if value < 0:
            raise ValueError("Age can't be negative")
        self._age = value

p = Person("Alice", 30)
p.set_age(31)           # verbose and un-Pythonic
print(p.get_age())      # 31
```

This works, but it's not idiomatic Python.

---

#### The Pythonic way — `@property` ✅

`@property` lets you write getter/setter logic while still using **clean attribute-style access**.

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age        # this calls the setter below!

    @property
    def age(self):            # GETTER — called on p.age
        return self._age

    @age.setter
    def age(self, value):     # SETTER — called on p.age = x
        if value < 0:
            raise ValueError("Age can't be negative")
        self._age = value

    @age.deleter
    def age(self):            # DELETER — called on del p.age
        print("Deleting age...")
        del self._age

p = Person("Alice", 30)
print(p.age)     # 30  → calls getter
p.age = 31       # → calls setter (with validation)
p.age = -5       # ❌ ValueError: Age can't be negative
del p.age        # → calls deleter
```

The magic: **the calling code looks identical whether or not there's validation logic behind it.** You can start with a plain attribute and add a `@property` later without breaking any existing code.

---

#### Read-only property (getter only, no setter)

```python
class Circle:
    def __init__(self, radius):
        self.radius = radius

    @property
    def area(self):                      # computed, read-only
        return 3.14159 * self.radius ** 2

c = Circle(5)
print(c.area)    # 78.53   ← looks like an attribute
c.area = 100     # ❌ AttributeError: can't set attribute
```

This is great for **computed attributes** — values derived from other data that shouldn't be set directly.

---

### 3. A Complete Example

```python
class BankAccount:
    def __init__(self, owner, balance=0):
        self.owner = owner
        self.balance = balance          # calls setter

    @property
    def balance(self):
        return self._balance

    @balance.setter
    def balance(self, amount):
        if amount < 0:
            raise ValueError("Balance cannot be negative")
        self._balance = amount

    @property
    def status(self):                   # read-only computed property
        if self._balance == 0:
            return "empty"
        elif self._balance < 500:
            return "low"
        return "healthy"

    def deposit(self, amount):
        self.balance += amount          # reuses setter validation

    def withdraw(self, amount):
        if amount > self._balance:
            raise ValueError("Insufficient funds")
        self.balance -= amount

acc = BankAccount("Alice", 1000)
acc.deposit(500)
print(acc.balance)   # 1500
print(acc.status)    # healthy
acc.withdraw(200)
print(acc.balance)   # 1300
```

---

### Summary

| Concept | Python mechanism | Key point |
|---|---|---|
| Constructor | `__init__` | Runs automatically on object creation |
| Multiple constructors | `@classmethod` | Alternate ways to build an object |
| Getter | `@property` | Access attribute with validation/logic |
| Setter | `@property_name.setter` | Set attribute with validation/logic |
| Deleter | `@property_name.deleter` | Custom logic when `del obj.attr` is called |
| Read-only attribute | `@property` with no setter | Computed values that can't be assigned |

The key Pythonic principle: **start with plain attributes, add `@property` only when you need validation or computed values** — and the calling code never needs to change.