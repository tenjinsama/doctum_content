
## Use instance attribute when you just **store** a value, `@property` when you need **control**

---

### Plain instance attribute — just storing data

```python
class User:
    def __init__(self, name, age):
        self.name = name    # stored directly, no logic
        self.age = age      # anyone can read/write freely
```
Simple, fast, no overhead. Use this by default.

---

### `@property` — when plain storage isn't enough

There are exactly 4 situations where you upgrade to `@property`:

---

**1. You need to validate on write**
```python
class User:
    def __init__(self, name, age):
        self.name = name
        self.age = age         # calls the setter below

    @property
    def age(self):
        return self._age

    @age.setter
    def age(self, value):
        if value < 0 or value > 150:
            raise ValueError(f"Invalid age: {value}")
        self._age = value

u = User("Alice", 30)
u.age = -5    # ← ValueError immediately
u.age = 31    # ✅
```
Without this, `u.age = -5` silently corrupts your object.

---

**2. The value is derived from other attributes**
```python
class Rectangle:
    def __init__(self, width, height):
        self.width = width     # stored
        self.height = height   # stored

    @property
    def area(self):            # derived — never stored, always fresh
        return self.width * self.height

r = Rectangle(4, 5)
print(r.area)   # 20
r.width = 10
print(r.area)   # 50 — automatically correct
```
If you stored `self.area = width * height` in `__init__`, it would go stale when `width` changes.

---

**3. You want read-only access**
```python
class Circle:
    def __init__(self, radius):
        self._radius = radius

    @property
    def radius(self):
        return self._radius
    # no setter → radius is frozen after init

c = Circle(5)
print(c.radius)  # 5   ✅
c.radius = 10    # ← AttributeError: can't set attribute
```

---

**4. You need side effects on read or write**
```python
class Temperature:
    def __init__(self, celsius):
        self._celsius = celsius

    @property
    def celsius(self):
        return self._celsius

    @celsius.setter
    def celsius(self, value):
        print(f"Temperature changed to {value}°C")   # logging
        self._celsius = value

    @property
    def fahrenheit(self):                             # computed on the fly
        return self._celsius * 9/5 + 32

t = Temperature(0)
t.celsius = 100     # prints: "Temperature changed to 100°C"
print(t.fahrenheit) # 212.0
```

---

### The key mental model

```
self.x = value          →  a box that holds a value
                            fast, simple, no logic

@property def x(self)   →  a door with a lock
                            you control what happens on read/write
```

---

### Summary table

| Situation | Use |
|---|---|
| Just storing a value | instance attribute |
| Validation on write | `@property` + setter |
| Value derived from other attributes | `@property` |
| Read-only after init | `@property` no setter |
| Logging / side effects on access | `@property` |

The practical rule: **start with a plain instance attribute, upgrade to `@property` only when you hit one of these 4 needs.**