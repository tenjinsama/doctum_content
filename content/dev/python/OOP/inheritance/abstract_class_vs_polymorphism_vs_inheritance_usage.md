These three OOP concepts are related but serve different purposes. Here's when to use each:

## Inheritance
Use when you have a clear **"is-a" relationship** and want to **reuse code** from a parent class.

```python
class Animal:
    def __init__(self, name):
        self.name = name

    def breathe(self):  # Shared behavior — no need to rewrite
        return f"{self.name} breathes air"

class Dog(Animal):
    def bark(self):
        return "Woof!"

class Cat(Animal):
    def meow(self):
        return "Meow!"

dog = Dog("Rex")
print(dog.breathe())  # Inherited — "Rex breathes air"
```

✅ Use when: subclasses genuinely *are* a type of the parent, and you want to share real implementation.  
❌ Avoid when: you're inheriting just to reuse a few methods — prefer composition instead.

---

## Polymorphism
Use when you want **different classes to be used interchangeably** through a shared interface, without caring about the concrete type.

```python
class Shape:
    def area(self): ...

class Circle(Shape):
    def __init__(self, r): self.r = r
    def area(self): return 3.14 * self.r ** 2

class Rectangle(Shape):
    def __init__(self, w, h): self.w, self.h = w, h
    def area(self): return self.w * self.h

def print_area(shape: Shape):  # Doesn't care which shape it is
    print(shape.area())

print_area(Circle(5))       # 78.5
print_area(Rectangle(4, 6)) # 24
```

✅ Use when: you process a collection of mixed types uniformly, or write functions that work on any object with a given method.

---

## Abstract Class
Use when you want to **enforce a contract** — subclasses *must* implement certain methods, but the base class itself shouldn't be instantiated.

```python
from abc import ABC, abstractmethod

class PaymentProcessor(ABC):
    @abstractmethod
    def charge(self, amount: float): ...  # Every subclass MUST implement this

    @abstractmethod
    def refund(self, amount: float): ...

class StripeProcessor(PaymentProcessor):
    def charge(self, amount): return f"Stripe charged ${amount}"
    def refund(self, amount): return f"Stripe refunded ${amount}"

class PaypalProcessor(PaymentProcessor):
    def charge(self, amount): return f"PayPal charged ${amount}"
    def refund(self, amount): return f"PayPal refunded ${amount}"

# PaymentProcessor()  ← raises TypeError, can't instantiate
```

✅ Use when: you're defining a plugin system, a framework interface, or any API where you want to guarantee methods exist on all implementors.

---

## Quick Decision Guide

| Question | Answer → Use |
|---|---|
| Do subclasses share real, working code? | **Inheritance** |
| Do you need to treat different types uniformly? | **Polymorphism** |
| Do you need to *enforce* that subclasses implement specific methods? | **Abstract Class** |
| All three at once? | Very common — they're complementary |

In practice, **abstract classes + polymorphism** go hand-in-hand: the abstract class defines the contract, and polymorphism lets you use any concrete implementation interchangeably.