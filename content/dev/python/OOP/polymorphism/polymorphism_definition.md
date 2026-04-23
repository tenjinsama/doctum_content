## Polymorphism in Python OOP

### What is it?

Polymorphism comes from Greek — *poly* (many) + *morphe* (forms). In OOP it means **the same interface (method name) can behave differently depending on the object it's called on**.

In simple terms: **one name, many behaviors.**

```python
# Same method name .speak() — totally different behavior
dog.speak()    # "Woof!"
cat.speak()    # "Meow!"
snake.speak()  # "Hiss!"
```

The caller doesn't need to know *what type* of object it has — it just calls the method and the right behavior kicks in automatically.

---

### Why does it matter?

Without polymorphism:
```python
# ❌ You have to check the type manually — fragile and unscalable
def make_sound(animal):
    if type(animal) == Dog:
        print("Woof!")
    elif type(animal) == Cat:
        print("Meow!")
    elif type(animal) == Snake:
        print("Hiss!")
    # every new animal breaks this function
```

With polymorphism:
```python
# ✅ Just call the method — works for any animal, present or future
def make_sound(animal):
    print(animal.speak())
```

---

### 1. Method Overriding Polymorphism

The most common form — child classes **override** a parent method with their own behavior:

```python
class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):
        return "Some generic sound"

    def describe(self):
        return f"I am {self.name}"

class Dog(Animal):
    def speak(self):
        return f"{self.name} says: Woof!"

class Cat(Animal):
    def speak(self):
        return f"{self.name} says: Meow!"

class Snake(Animal):
    def speak(self):
        return f"{self.name} says: Hiss!"

class Fish(Animal):
    pass                    # no override — uses Animal.speak()


animals = [Dog("Rex"), Cat("Whiskers"), Snake("Sly"), Fish("Nemo")]

for animal in animals:
    print(animal.speak())   # correct method called automatically

# Rex says: Woof!
# Whiskers says: Meow!
# Sly says: Hiss!
# Some generic sound
```

The `for` loop doesn't care about types — it just calls `.speak()` and polymorphism handles the rest.

---

### 2. Duck Typing Polymorphism

Python's most powerful and flexible form of polymorphism. The idea:

> *"If it walks like a duck and quacks like a duck, it's a duck."*

Classes don't need to share a parent — they just need to implement the **same method name**:

```python
class Dog:
    def speak(self):
        return "Woof!"

class Robot:
    def speak(self):
        return "Beep boop!"

class Human:
    def speak(self):
        return "Hello!"

class Baby:
    def speak(self):
        return "Goo goo!"


# No shared parent — yet this works perfectly
def make_speak(entity):
    print(entity.speak())

speakers = [Dog(), Robot(), Human(), Baby()]
for s in speakers:
    make_speak(s)

# Woof!
# Beep boop!
# Hello!
# Goo goo!
```

Python doesn't check *what type* the object is — only *whether it has the method*. This is duck typing.

---

### 3. Operator Overloading Polymorphism

The `+` operator behaves differently depending on the type — that's polymorphism too. You can define this for your own classes using **dunder methods**:

```python
class Vector:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __add__(self, other):          # overloads +
        return Vector(self.x + other.x, self.y + other.y)

    def __mul__(self, scalar):         # overloads *
        return Vector(self.x * scalar, self.y * scalar)

    def __eq__(self, other):           # overloads ==
        return self.x == other.x and self.y == other.y

    def __str__(self):
        return f"Vector({self.x}, {self.y})"

    def __len__(self):                 # overloads len()
        return int((self.x**2 + self.y**2) ** 0.5)


v1 = Vector(2, 3)
v2 = Vector(1, 4)

print(v1 + v2)     # Vector(3, 7)   — calls __add__
print(v1 * 3)      # Vector(6, 9)   — calls __mul__
print(v1 == v2)    # False          — calls __eq__
print(len(v1))     # 3              — calls __len__
```

Same operator symbol (`+`, `*`, `==`) — totally different behavior based on the object type.

---

### 4. Abstract Class Polymorphism

Use abstract base classes to **enforce** that every subclass implements a required method — a formal contract:

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self):
        pass

    @abstractmethod
    def perimeter(self):
        pass

    def describe(self):                          # shared, non-abstract
        return (f"{type(self).__name__}: "
                f"area={self.area():.2f}, "
                f"perimeter={self.perimeter():.2f}")

class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return 3.14159 * self.radius ** 2

    def perimeter(self):
        return 2 * 3.14159 * self.radius

class Rectangle(Shape):
    def __init__(self, w, h):
        self.w = w
        self.h = h

    def area(self):
        return self.w * self.h

    def perimeter(self):
        return 2 * (self.w + self.h)

class Triangle(Shape):
    def __init__(self, a, b, c, height):
        self.a, self.b, self.c = a, b, c
        self.height = height

    def area(self):
        return 0.5 * self.a * self.height

    def perimeter(self):
        return self.a + self.b + self.c


shapes = [Circle(5), Rectangle(4, 6), Triangle(3, 4, 5, 4)]
for shape in shapes:
    print(shape.describe())

# Circle:    area=78.54, perimeter=31.42
# Rectangle: area=24.00, perimeter=20.00
# Triangle:  area=6.00,  perimeter=12.00

# Shape()   ❌ TypeError — can't instantiate abstract class
```

---

### 5. Built-in Polymorphism

Python's built-in functions are themselves polymorphic:

```python
# len() works on any object that implements __len__
print(len("hello"))        # 5   — string
print(len([1, 2, 3]))      # 3   — list
print(len({"a": 1}))       # 1   — dict

# + works differently based on type
print(1 + 2)               # 3          — addition
print("Hello" + " World")  # Hello World — concatenation
print([1, 2] + [3, 4])     # [1, 2, 3, 4] — list merge

# str() works on anything
print(str(42))             # "42"
print(str(3.14))           # "3.14"
print(str(True))           # "True"
```

---

### 6. A Complete Real-World Example

```python
from abc import ABC, abstractmethod

class PaymentMethod(ABC):
    def __init__(self, owner):
        self.owner = owner

    @abstractmethod
    def pay(self, amount):
        pass

    @abstractmethod
    def refund(self, amount):
        pass

    def receipt(self, amount):
        return f"[{type(self).__name__}] {self.owner} — ${amount:.2f}"


class CreditCard(PaymentMethod):
    def __init__(self, owner, limit):
        super().__init__(owner)
        self.limit = limit

    def pay(self, amount):
        if amount > self.limit:
            return f"❌ Exceeds credit limit of ${self.limit}"
        return f"✅ Credit card charged ${amount:.2f}. {self.receipt(amount)}"

    def refund(self, amount):
        return f"↩️  Refunded ${amount:.2f} to credit card."


class PayPal(PaymentMethod):
    def __init__(self, owner, email):
        super().__init__(owner)
        self.email = email

    def pay(self, amount):
        return f"✅ PayPal payment of ${amount:.2f} via {self.email}. {self.receipt(amount)}"

    def refund(self, amount):
        return f"↩️  Refunded ${amount:.2f} to PayPal account {self.email}."


class Crypto(PaymentMethod):
    def __init__(self, owner, wallet):
        super().__init__(owner)
        self.wallet = wallet

    def pay(self, amount):
        return f"✅ Crypto payment of ${amount:.2f} from wallet {self.wallet}. {self.receipt(amount)}"

    def refund(self, amount):
        return f"↩️  Crypto refund of ${amount:.2f} to {self.wallet}."


# Polymorphic function — works with ANY payment method
def checkout(payment: PaymentMethod, amount: float):
    print(payment.pay(amount))

def process_refund(payment: PaymentMethod, amount: float):
    print(payment.refund(amount))


payments = [
    CreditCard("Alice", limit=2000),
    PayPal("Bob", "bob@email.com"),
    Crypto("Carol", "0xABC123"),
]

for method in payments:
    checkout(method, 150.00)

print()

for method in payments:
    process_refund(method, 50.00)
```

Output:
```
✅ Credit card charged $150.00. [CreditCard] Alice — $150.00
✅ PayPal payment of $150.00 via bob@email.com. [PayPal] Bob — $150.00
✅ Crypto payment of $150.00 from wallet 0xABC123. [Crypto] Carol — $150.00

↩️  Refunded $50.00 to credit card.
↩️  Refunded $50.00 to PayPal account bob@email.com.
↩️  Crypto refund of $50.00 to 0xABC123.
```

`checkout()` and `process_refund()` never check the type — they just call `.pay()` and `.refund()`, and polymorphism routes to the right implementation.

---

### Types of Polymorphism — Summary

```
Polymorphism in Python
 │
 ├── Method Overriding   → Child redefines parent's method
 │                          Dog.speak() overrides Animal.speak()
 │
 ├── Duck Typing         → No shared parent needed
 │                          "if it has the method, it works"
 │
 ├── Operator Overloading → Same operator, different behavior
 │                          + means add for int, concat for str
 │
 └── Abstract Classes    → Enforced interface contract
                            every subclass MUST implement the method
```

The core idea: **write code against interfaces, not concrete types** — your functions and loops work with any object that has the right methods, making your code open to extension without modification.