## `@dataclass` vs Normal Class

### Use `@dataclass` when your class is primarily **data storage**

```python
from dataclasses import dataclass, field
from typing import List

@dataclass
class Product:
    name: str
    price: float
    tags: List[str] = field(default_factory=list)
    in_stock: bool = True

# You get these for free:
p1 = Product("Laptop", 999.99)
p2 = Product("Laptop", 999.99)

print(p1)          # Product(name='Laptop', price=999.99, tags=[], in_stock=True)
print(p1 == p2)    # True  (__eq__ auto-generated)
```

You get `__init__`, `__repr__`, and `__eq__` **auto-generated** — no boilerplate.

---

### Use a normal class when your class has **behavior and logic**

```python
class BankAccount:
    def __init__(self, owner: str, balance: float = 0):
        self.owner = owner
        self._balance = balance  # private, needs protection

    def deposit(self, amount: float):
        if amount <= 0:
            raise ValueError("Amount must be positive")
        self._balance += amount

    def withdraw(self, amount: float):
        if amount > self._balance:
            raise ValueError("Insufficient funds")
        self._balance -= amount

    @property
    def balance(self):
        return self._balance
```

The logic inside `deposit`/`withdraw` wouldn't make sense in a dataclass.

---

### Key differences at a glance

| Feature | `@dataclass` | Normal Class |
|---|---|---|
| `__init__` | ✅ Auto-generated | ✍️ Manual |
| `__repr__` | ✅ Auto-generated | ✍️ Manual |
| `__eq__` | ✅ Auto-generated | ✍️ Manual |
| `__hash__` | ⚙️ Via `frozen=True` | ✍️ Manual |
| Immutability | ⚙️ Via `frozen=True` | ✍️ Manual |
| Complex validation | ❌ Awkward | ✅ Natural |
| Private attributes | ❌ Not idiomatic | ✅ Natural |
| Inheritance | ⚠️ Works but tricky | ✅ Natural |

---

### `@dataclass` power features worth knowing

**`frozen=True`** — makes instances immutable and hashable (usable in sets/dicts):
```python
@dataclass(frozen=True)
class Point:
    x: float
    y: float

p = Point(1.0, 2.0)
# p.x = 5  ← raises FrozenInstanceError
my_set = {p}  # ✅ hashable
```

**`__post_init__`** — for validation after auto-init:
```python
@dataclass
class Rectangle:
    width: float
    height: float

    def __post_init__(self):
        if self.width <= 0 or self.height <= 0:
            raise ValueError("Dimensions must be positive")
```

**`field()`** — for fine-grained control:
```python
@dataclass
class User:
    name: str
    password: str = field(repr=False)   # hidden from __repr__
    id: int = field(default_factory=lambda: random.randint(1000, 9999))
```

---

### Quick decision rule

```
Does the class primarily HOLD data with little logic?
├── Yes → @dataclass
│         ├── Needs to be immutable/hashable? → frozen=True
│         └── Light validation? → __post_init__
└── No  → Normal class
          ├── Complex logic, private state, properties → Normal class
          └── Just a namespace/config with no methods → consider dataclass anyway
```

A good real-world signal: if you find yourself writing `__init__` with lines like `self.x = x` repeated 5+ times and nothing else — that's a `@dataclass`.