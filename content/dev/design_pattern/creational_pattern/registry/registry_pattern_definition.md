## Registry Design Pattern

The **Registry pattern** is a well-known software design pattern used to keep track of objects, classes, or services under a central store — essentially a "lookup table" that maps names/keys to instances or factories.

### Core Idea

Instead of hardcoding dependencies or using scattered `if/elif` chains, you register components by name into a central dictionary, then retrieve them dynamically at runtime.

### How it works

There are typically three parts:

1. **The Registry** — a central store (usually a dict) that maps keys to classes/functions/instances.
2. **Registration** — a way to add entries (manually, via decorators, or auto-discovery).
3. **Lookup** — a way to retrieve and use a component by its key.

### Simple Example (Python)

```python
# 1. The registry
_registry = {}

# 2. A decorator to register classes
def register(name):
    def decorator(cls):
        _registry[name] = cls
        return cls
    return decorator

# 3. Register components
@register("csv")
class CSVParser:
    def parse(self, data): ...

@register("json")
class JSONParser:
    def parse(self, data): ...

# 4. Lookup and use
def get_parser(fmt):
    return _registry[fmt]()

parser = get_parser("json")
```

### The same pattern in Java

```java
// Registry
Map<String, Parser> registry = new HashMap<>();

// Register
registry.put("csv", new CSVParser());
registry.put("json", new JSONParser());

// Lookup
Parser parser = registry.get("json");
```

### The same pattern in JavaScript/TypeScript

```typescript
const registry: Record<string, new () => Parser> = {};

function register(name: string, cls: new () => Parser) {
  registry[name] = cls;
}

register("json", JSONParser);

const parser = new registry["json"]();
```

---

## Is it Python-specific?

**No, not at all.** The Registry pattern is **language-agnostic**. It appears across virtually every language and ecosystem:

| Language / Ecosystem | Example usage |
|---|---|
| **Java** | Spring's `BeanFactory`, servlet mappings |
| **C#/.NET** | IoC containers like Autofac, `ServiceCollection` |
| **JavaScript/Node** | Express middleware, plugin systems |
| **Go** | `database/sql` driver registration via `sql.Register()` |
| **Ruby** | Rails' autoloading and plugin system |
| **Python** | Django's app registry, Celery tasks, Click CLI commands |

Python does make the pattern feel *particularly natural* because decorators are a first-class, clean way to register things — which is why you see it so often in Python frameworks. But the concept predates Python and is widely used everywhere.

---

## When to use it

The Registry pattern shines when you need:
- **Plugin/extension systems** — let third parties register new handlers without modifying core code.
- **Strategy selection at runtime** — pick an algorithm or handler by name from config or user input.
- **Decoupling** — the caller doesn't need to `import` concrete classes directly; it just asks the registry.
- **Open/Closed principle** — add new behaviors by registration, without changing existing code.