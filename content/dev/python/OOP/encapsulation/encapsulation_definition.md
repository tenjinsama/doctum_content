## Encapsulation in Python OOP

### What is it?

Encapsulation is the principle of **bundling data (attributes) and the methods that operate on that data together inside a class**, while **restricting direct access** to the internal state from outside. It's about controlling *who can see and modify* what.

Think of it like a **capsule** — the internals are protected, and you only interact through a defined interface.

---

### Why does it matter?

Without encapsulation:
```python
class BankAccount:
    def __init__(self, balance):
        self.balance = balance   # fully exposed

acc = BankAccount(1000)
acc.balance = -99999             # ❌ nothing stops this — data is corrupted
```

With encapsulation:
```python
class BankAccount:
    def __init__(self, balance):
        self.__balance = balance  # protected

    def deposit(self, amount):
        if amount > 0:
            self.__balance += amount

acc = BankAccount(1000)
acc.__balance = -99999           # ❌ has no effect on the real internal state
acc.deposit(-500)                # controlled, validated access
```

---

### 1. Access Levels

Python doesn't enforce access control like Java or C++. Instead it uses **naming conventions** as signals:

```python
class Person:
    def __init__(self):
        self.name = "Alice"       # public
        self._nickname = "Ali"    # protected (convention)
        self.__ssn = "123-45"     # private (name-mangled)
```

#### Public — `name`
```python
class Car:
    def __init__(self, brand):
        self.brand = brand        # anyone can read/write

c = Car("Toyota")
print(c.brand)      # Toyota  ✅
c.brand = "Honda"   # ✅ allowed
```

#### Protected — `_name`
A single underscore is a **convention** meaning *"internal use — don't touch from outside unless you know what you're doing."* Python does NOT enforce this.

```python
class Car:
    def __init__(self, brand):
        self._engine_code = "V8-001"   # intended for internal/subclass use

c = Car("Toyota")
print(c._engine_code)    # ⚠️ works, but you're breaking convention
```

#### Private — `__name`
A double underscore triggers **name mangling** — Python renames it internally to `_ClassName__attribute`, making accidental access from outside much harder.

```python
class Car:
    def __init__(self, brand):
        self.__vin = "ABC123"     # private

c = Car("Toyota")
print(c.__vin)             # ❌ AttributeError
print(c._Car__vin)         # ⚠️ works (mangled name) — but don't do this
```

---

### 2. Controlled Access with `@property`

The Pythonic way to expose internal data safely — with validation logic hidden behind clean attribute-style access:

```python
class Employee:
    def __init__(self, name, salary):
        self.name = name
        self.salary = salary          # triggers setter

    @property
    def salary(self):                 # getter
        return self.__salary

    @salary.setter
    def salary(self, value):          # setter with validation
        if value < 0:
            raise ValueError("Salary cannot be negative")
        if value > 1_000_000:
            raise ValueError("Salary seems unrealistic")
        self.__salary = value

    @property
    def annual(self):                 # read-only computed property
        return self.__salary * 12

e = Employee("Alice", 5000)
print(e.salary)      # 5000   → calls getter
print(e.annual)      # 60000  → computed, read-only
e.salary = 6000      # ✅ calls setter
e.salary = -100      # ❌ ValueError
```

---

### 3. A Full Real-World Example

```python
class BankAccount:
    __interest_rate = 0.03          # private CLASS attribute

    def __init__(self, owner, balance=0):
        self.__owner = owner
        self.__balance = 0
        self.__transactions = []
        self.balance = balance      # use setter for initial validation

    # --- Getters ---
    @property
    def owner(self):
        return self.__owner

    @property
    def balance(self):
        return self.__balance

    @property
    def transactions(self):
        return list(self.__transactions)   # return a copy, not the real list

    # --- Setter ---
    @balance.setter
    def balance(self, amount):
        if amount < 0:
            raise ValueError("Balance cannot be negative")
        self.__balance = amount

    # --- Public interface (methods) ---
    def deposit(self, amount):
        if amount <= 0:
            raise ValueError("Deposit must be positive")
        self.__balance += amount
        self.__transactions.append(f"Deposited: +{amount}")

    def withdraw(self, amount):
        if amount <= 0:
            raise ValueError("Amount must be positive")
        if amount > self.__balance:
            raise ValueError("Insufficient funds")
        self.__balance -= amount
        self.__transactions.append(f"Withdrew: -{amount}")

    def apply_interest(self):
        interest = self.__balance * BankAccount.__interest_rate
        self.__balance += interest
        self.__transactions.append(f"Interest: +{interest:.2f}")

    def __str__(self):
        return f"Account({self.__owner}, balance={self.__balance})"


acc = BankAccount("Alice", 1000)
acc.deposit(500)
acc.withdraw(200)
acc.apply_interest()

print(acc)                   # Account(Alice, balance=1339.0)
print(acc.balance)           # 1339.0
print(acc.transactions)      # ['Deposited: +500', 'Withdrew: -200', 'Interest: +39.00']

# What outsiders CANNOT do:
# acc.__balance = 999999     ❌ won't affect real balance
# acc.__transactions = []    ❌ same — name-mangled
# acc.transactions.append()  ❌ modifies a copy, not the real list
```

---

### 4. Access Level Summary

```
┌─────────────────┬──────────────┬────────────────────────┬─────────────────┐
│ Syntax          │ Level        │ Accessible from         │ Enforced?       │
├─────────────────┼──────────────┼────────────────────────┼─────────────────┤
│ self.name       │ Public       │ Anywhere                │ No restriction  │
│ self._name      │ Protected    │ Class + subclasses      │ Convention only │
│ self.__name     │ Private      │ Class only (mangled)    │ Name mangling   │
└─────────────────┴──────────────┴────────────────────────┴─────────────────┘
```

---

### Key Takeaways

- Encapsulation is about **protecting internal state** and exposing only what's necessary.
- Python relies on **conventions and `@property`** rather than hard enforcement.
- Use `__private` for truly sensitive internals, `_protected` for subclass-only internals, and `@property` for controlled, validated access.
- The goal is a **clean public interface** — outsiders interact through methods and properties, never raw internal data.

> *"We're all consenting adults here"* — Python's philosophy trusts developers to respect conventions rather than enforcing strict access control.