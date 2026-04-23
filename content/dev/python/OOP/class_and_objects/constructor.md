## Constructors

### 1. Constructor — `__init__`

The constructor is a special method automatically called when an object is **created**. Its job is to initialize the object's attributes.

```python
class Person:
    def __init__(self, name, age):   # constructor
        self.name = name
        self.age = age

p = Person("Alice", 30)  # __init__ is called automatically
print(p.name)  # Alice
```

Python actually has **two** creation-related dunders:

| Method | When it runs | Purpose |
|---|---|---|
| `__new__` | Before `__init__` | *Creates* the object in memory (rarely overridden) |
| `__init__` | After `__new__` | *Initializes* the object's attributes |

In practice, you almost always only use `__init__`. `__new__` is only needed for advanced cases like singletons or immutable types.

---

#### Default & optional parameters in the constructor

```python
class Car:
    def __init__(self, brand, color="white", year=2024):
        self.brand = brand
        self.color = color
        self.year = year

c1 = Car("Toyota")                    # uses defaults
c2 = Car("BMW", color="black")        # partial override
c3 = Car("Ford", "red", 2020)         # all specified

print(c1.color)   # white
print(c2.color)   # black
```

---

#### Multiple constructors with `@classmethod`

Python doesn't support method overloading, but you can fake multiple constructors using class methods:

```python
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    @classmethod
    def from_tuple(cls, coords):       # alternate constructor
        return cls(coords[0], coords[1])

    @classmethod
    def origin(cls):                   # another alternate constructor
        return cls(0, 0)

p1 = Point(3, 4)
p2 = Point.from_tuple((3, 4))
p3 = Point.origin()
```

