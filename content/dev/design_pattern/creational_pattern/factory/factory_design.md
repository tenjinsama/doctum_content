## Factory Method Pattern

The **Factory Method** is a creational design pattern that defines an interface for creating objects, but lets subclasses decide which class to instantiate. Instead of calling a constructor directly, you call a "factory method" that returns the appropriate object.

**Core idea:** defer object creation to subclasses, so the parent class doesn't need to know the exact type it's creating.

---

### Structure

```
Creator (abstract)
└── factory_method() → Product   ← subclasses override this
└── some_operation()             ← uses the product

ConcreteCreatorA → creates ProductA
ConcreteCreatorB → creates ProductB
```

---

### Python Example**Output:**
```
=== Factory Method — Notification Demo ===

[EMAIL → alice@example.com] Your order #4271 has shipped!
[SMS → +33612345678] Your order #4271 has shipped!
[PUSH → abc123de...] Your order #4271 has shipped!
```

---

### How the pieces connect

| Role | In the example |
|---|---|
| **Product** (abstract) | `Notification` |
| **Concrete Products** | `EmailNotification`, `SMSNotification`, `PushNotification` |
| **Creator** (abstract) | `NotificationService` with `create_notification()` |
| **Concrete Creators** | `EmailService`, `SMSService`, `PushService` |

The crucial insight: `notify()` in the base class never changes — it just calls `create_notification()` and uses the result. The *what to build* is fully delegated to subclasses.

---

### Real-world use cases

**When should you reach for this pattern?**

- **You don't know ahead of time which type you'll need.** Example: a logger that writes to a file, stdout, or a remote service depending on config.
- **You want to isolate object-creation logic.** Adding a new channel (e.g. WhatsApp) only requires a new subclass — existing code is untouched (*Open/Closed Principle*).
- **You're building a framework or library.** You provide the skeleton (`Creator`), and users plug in their own products by subclassing.
- **Testing.** You can inject a `MockService` subclass that returns fake objects without touching production code.

**Examples in the wild:**
- `unittest.TestLoader` — decides which test class to instantiate
- Django's `AUTH_USER_MODEL` — swappable user model via a factory
- SQLAlchemy dialects — `create_engine("postgresql://...")` vs `create_engine("sqlite://...")` picks the right engine internally