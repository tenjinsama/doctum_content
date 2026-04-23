## Class Variable vs Instance Variable

`raise_amount` is a **class variable**, not a property. Here's what that means:

### Where it lives in memory

```python
class Employee:
    raise_amount = 1.05          # Stored on the CLASS itself

    def __init__(self, name, salary):
        self.name = name         # Stored on each INSTANCE
        self.salary = salary     # Stored on each INSTANCE
```

```python
emp1 = Employee("Alice", 50000)
emp2 = Employee("Bob", 60000)

# Class variable → shared by all
print(Employee.raise_amount)  # 1.05
print(emp1.raise_amount)      # 1.05  (looks up to class if not on instance)
print(emp2.raise_amount)      # 1.05

# Instance variables → unique per object
print(emp1.name)  # "Alice"
print(emp2.name)  # "Bob"
```

---

### The lookup chain (important!)

When you access `emp1.raise_amount`, Python follows this order:

```
emp1.__dict__  →  Employee.__dict__  →  parent classes...
```

```python
print(emp1.__dict__)     # {'name': 'Alice', 'salary': 50000}  ← no raise_amount
print(Employee.__dict__) # {'raise_amount': 1.05, ...}         ← found here
```

---

### Why use a class variable here?

Because `raise_amount` is the **same for all employees** — it's company policy, not personal:

```python
class Employee:
    raise_amount = 1.05

    def __init__(self, name, salary):
        self.name = name
        self.salary = salary

    def apply_raise(self):
        self.salary *= self.raise_amount  # uses class variable

emp1 = Employee("Alice", 50000)
emp2 = Employee("Bob", 60000)

# Change for ALL employees at once
Employee.raise_amount = 1.10
print(emp1.raise_amount)  # 1.10
print(emp2.raise_amount)  # 1.10
```

---

### Careful: setting it on an instance shadows the class variable

```python
emp1.raise_amount = 1.20   # creates a NEW instance variable on emp1 only

print(emp1.raise_amount)      # 1.20  ← instance variable (shadows class var)
print(emp2.raise_amount)      # 1.05  ← still uses class variable
print(Employee.raise_amount)  # 1.05  ← class variable unchanged

print(emp1.__dict__)  # {'name': 'Alice', 'salary': 50000, 'raise_amount': 1.20}
```

This doesn't modify the class — it creates a **separate copy on that instance**.

---

### Is it a `@property`? No — here's the difference

```python
class Employee:
    raise_amount = 1.05          # plain class variable — just a value

    @property
    def annual_bonus(self):      # property — computed dynamically on access
        return self.salary * 0.10
```

| | Class Variable | `@property` |
|---|---|---|
| Stored as | A value on the class | A descriptor/function |
| Accessed via | `self.x` or `Class.x` | `self.x` only |
| Computed? | No, static value | Yes, runs code each time |
| Settable on instance? | Yes (shadows class var) | Only with `@x.setter` |

---

### When to put something as a class variable

Use a class variable when the value is:
- **Shared** across all instances (company policy, constants, counters)
- **Not unique** per object

```python
class Employee:
    raise_amount = 1.05      # ✅ same for all employees
    company = "Acme Corp"    # ✅ same for all employees
    employee_count = 0       # ✅ shared counter

    def __init__(self, name, salary):
        self.name = name     # ✅ unique per employee
        self.salary = salary # ✅ unique per employee
        Employee.employee_count += 1
```