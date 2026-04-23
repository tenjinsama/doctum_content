## Inheritance in Python OOP

### What is it?

Inheritance is the mechanism that allows a class to **acquire attributes and methods from another class**. The class that inherits is called the **child (subclass)**, and the class being inherited from is the **parent (superclass/base class)**.

It models an **"is-a" relationship** — a `Dog` *is an* `Animal`, a `Car` *is a* `Vehicle`.

The core benefits:
- **Code reuse** — don't rewrite what already exists
- **Extensibility** — add new behavior without modifying the parent
- **Hierarchy** — model real-world relationships naturally

---

### 1. Basic Inheritance

```python
class Animal:                          # Parent class
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def eat(self):
        return f"{self.name} is eating"

    def sleep(self):
        return f"{self.name} is sleeping"

class Dog(Animal):                     # Child class — inherits from Animal
    def bark(self):                    # new method, only for Dog
        return f"{self.name} says: Woof!"

class Cat(Animal):                     # Another child class
    def meow(self):
        return f"{self.name} says: Meow!"


dog = Dog("Rex", 3)
cat = Cat("Whiskers", 5)

# Dog and Cat inherit eat() and sleep() from Animal
print(dog.eat())      # Rex is eating
print(cat.sleep())    # Whiskers is sleeping

# Their own methods
print(dog.bark())     # Rex says: Woof!
print(cat.meow())     # Whiskers says: Meow!
```

`Dog` and `Cat` got `eat()` and `sleep()` for free — no repetition.

---

### 2. Method Overriding

A child class can **replace** a parent method with its own version:

```python
class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):
        return "Some generic sound"

    def describe(self):
        return f"I am {self.name}"

class Dog(Animal):
    def speak(self):                        # overrides Animal.speak
        return f"{self.name} says: Woof!"

class Cat(Animal):
    def speak(self):                        # overrides Animal.speak
        return f"{self.name} says: Meow!"

class Snake(Animal):
    pass                                    # no override — uses Animal.speak


animals = [Dog("Rex"), Cat("Whiskers"), Snake("Sly")]
for a in animals:
    print(a.speak())

# Rex says: Woof!
# Whiskers says: Meow!
# Some generic sound      ← Snake uses the parent's version
```

---

### 3. Extending with `super()`

Instead of fully replacing a parent method, you can **extend it** — run the parent's logic first, then add more:

```python
class Animal:
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def describe(self):
        return f"Name: {self.name}, Age: {self.age}"

class Dog(Animal):
    def __init__(self, name, age, breed):
        super().__init__(name, age)          # run Animal's init first
        self.breed = breed                   # then add Dog-specific attr

    def describe(self):
        base = super().describe()            # reuse Animal's describe
        return f"{base}, Breed: {self.breed}"

class GuideDog(Dog):
    def __init__(self, name, age, breed, owner):
        super().__init__(name, age, breed)   # run Dog's init first
        self.owner = owner

    def describe(self):
        base = super().describe()            # reuse Dog's describe
        return f"{base}, Owner: {self.owner}"


g = GuideDog("Rex", 3, "Labrador", "Alice")
print(g.describe())
# Name: Rex, Age: 3, Breed: Labrador, Owner: Alice
```

Each level builds on the one above — no logic is repeated.

---

### 4. Types of Inheritance

#### Single Inheritance — one parent
```python
class Vehicle:
    def move(self):
        return "Moving..."

class Car(Vehicle):        # Car → Vehicle
    def honk(self):
        return "Beep!"
```

#### Multi-level Inheritance — chain of parents
```python
class Animal:
    def breathe(self):
        return "Breathing"

class Mammal(Animal):      # Mammal → Animal
    def walk(self):
        return "Walking"

class Dog(Mammal):         # Dog → Mammal → Animal
    def bark(self):
        return "Woof!"

d = Dog()
print(d.breathe())   # ✅ from Animal
print(d.walk())      # ✅ from Mammal
print(d.bark())      # ✅ own method
```

#### Multiple Inheritance — more than one parent
```python
class Flyable:
    def fly(self):
        return "Flying!"

class Swimmable:
    def swim(self):
        return "Swimming!"

class Duck(Flyable, Swimmable):    # inherits from both
    def quack(self):
        return "Quack!"

d = Duck()
print(d.fly())    # Flying!
print(d.swim())   # Swimming!
print(d.quack())  # Quack!
```

#### Hierarchical Inheritance — multiple children, one parent
```python
class Shape:
    def area(self):
        return 0

class Circle(Shape):       # Circle → Shape
    def __init__(self, r):
        self.r = r
    def area(self):
        return 3.14 * self.r ** 2

class Rectangle(Shape):    # Rectangle → Shape
    def __init__(self, w, h):
        self.w, self.h = w, h
    def area(self):
        return self.w * self.h
```

---

### 5. `isinstance()` and `issubclass()`

Useful built-ins for checking inheritance relationships:

```python
class Animal: pass
class Dog(Animal): pass
class Cat(Animal): pass

d = Dog()

print(isinstance(d, Dog))      # True  — d is a Dog
print(isinstance(d, Animal))   # True  — Dog IS-A Animal
print(isinstance(d, Cat))      # False

print(issubclass(Dog, Animal)) # True  — Dog is a subclass of Animal
print(issubclass(Cat, Animal)) # True
print(issubclass(Dog, Cat))    # False
```

---

### 6. A Complete Real-World Example

```python
class Employee:
    def __init__(self, name, emp_id, base_salary):
        self.name = name
        self.emp_id = emp_id
        self.base_salary = base_salary

    def get_salary(self):
        return self.base_salary

    def describe(self):
        return (f"ID: {self.emp_id} | Name: {self.name} "
                f"| Salary: {self.get_salary()}")


class Manager(Employee):
    def __init__(self, name, emp_id, base_salary, bonus):
        super().__init__(name, emp_id, base_salary)
        self.bonus = bonus
        self.team = []

    def get_salary(self):                        # override
        return self.base_salary + self.bonus

    def add_to_team(self, employee):
        self.team.append(employee)
        return f"{employee.name} added to {self.name}'s team"


class Intern(Employee):
    def __init__(self, name, emp_id, base_salary, duration_months):
        super().__init__(name, emp_id, base_salary)
        self.duration_months = duration_months

    def get_salary(self):                        # override
        return self.base_salary * 0.5            # interns get half

    def describe(self):
        base = super().describe()                # extend parent
        return f"{base} | Intern for {self.duration_months} months"


# Usage
manager = Manager("Alice", "M001", 8000, 2000)
dev     = Employee("Bob", "E001", 5000)
intern_ = Intern("Carol", "I001", 2000, 6)

manager.add_to_team(dev)
manager.add_to_team(intern_)

staff = [manager, dev, intern_]
for person in staff:
    print(person.describe())

# ID: M001 | Name: Alice | Salary: 10000
# ID: E001 | Name: Bob   | Salary: 5000
# ID: I001 | Name: Carol | Salary: 1000 | Intern for 6 months
```

---

### Summary

```
Inheritance types
 ├── Single          → Child inherits from one parent
 ├── Multi-level     → Chain: GrandChild → Child → Parent
 ├── Multiple        → One child, many parents
 └── Hierarchical    → Many children, one parent

Key tools
 ├── super()         → Access parent class methods
 ├── Override        → Replace parent method in child
 ├── Extend          → Add to parent method via super()
 ├── isinstance()    → Check if object is instance of a class
 └── issubclass()    → Check class relationship
```

The golden rule: use inheritance when there is a genuine **"is-a" relationship**. If the relationship is **"has-a"** (e.g. a `Car` *has an* `Engine`), use **composition** instead — that's a topic of its own.