## Builder Design Pattern

The **Builder** pattern is a creational design pattern that separates the **construction** of a complex object from its **representation**. Instead of using a massive constructor with many parameters, you build the object step by step.

### Core Idea

Rather than `House(walls, roof, garage, pool, garden, ...)`, you do:
```
builder.add_walls().add_roof().add_garage().build()
```

### Key Components

- **Builder** – interface declaring construction steps
- **Concrete Builder** – implements the steps, tracks the product state
- **Director** – defines the order of building steps (optional)
- **Product** – the complex object being built

---

### Python Code Example

```python
from dataclasses import dataclass, field
from typing import Optional


# ── Product ──────────────────────────────────────────────────────────────────
@dataclass
class House:
    walls:    str
    roof:     str
    floors:   int
    garage:   bool              = False
    pool:     bool              = False
    garden:   Optional[str]     = None
    extras:   list[str]         = field(default_factory=list)

    def __str__(self):
        parts = [
            f"  Walls  : {self.walls}",
            f"  Roof   : {self.roof}",
            f"  Floors : {self.floors}",
            f"  Garage : {'yes' if self.garage else 'no'}",
            f"  Pool   : {'yes' if self.pool else 'no'}",
        ]
        if self.garden:
            parts.append(f"  Garden : {self.garden}")
        if self.extras:
            parts.append(f"  Extras : {', '.join(self.extras)}")
        return "House:\n" + "\n".join(parts)


# ── Builder ───────────────────────────────────────────────────────────────────
class HouseBuilder:
    def __init__(self):
        self.reset()

    def reset(self):
        self._walls   = "brick"
        self._roof    = "flat"
        self._floors  = 1
        self._garage  = False
        self._pool    = False
        self._garden  = None
        self._extras  = []
        return self

    # each method returns self → fluent / chainable API
    def set_walls(self, material: str):   self._walls  = material;  return self
    def set_roof(self, style: str):       self._roof   = style;     return self
    def set_floors(self, n: int):         self._floors = n;         return self
    def add_garage(self):                 self._garage = True;      return self
    def add_pool(self):                   self._pool   = True;      return self
    def add_garden(self, size: str):      self._garden = size;      return self
    def add_extra(self, feature: str):    self._extras.append(feature); return self

    def build(self) -> House:
        house = House(
            walls   = self._walls,
            roof    = self._roof,
            floors  = self._floors,
            garage  = self._garage,
            pool    = self._pool,
            garden  = self._garden,
            extras  = self._extras[:],
        )
        self.reset()   # ready for next build
        return house


# ── Director (optional) ───────────────────────────────────────────────────────
class HouseDirector:
    def __init__(self, builder: HouseBuilder):
        self._builder = builder

    def build_starter_home(self) -> House:
        return (self._builder
                .set_walls("wood")
                .set_roof("gabled")
                .set_floors(1)
                .build())

    def build_luxury_villa(self) -> House:
        return (self._builder
                .set_walls("stone")
                .set_roof("terracotta")
                .set_floors(3)
                .add_garage()
                .add_pool()
                .add_garden("large")
                .add_extra("home cinema")
                .add_extra("solar panels")
                .build())


# ── Client code ───────────────────────────────────────────────────────────────
builder  = HouseBuilder()
director = HouseDirector(builder)

print(director.build_starter_home())
print()
print(director.build_luxury_villa())
print()

# without the director — full custom control
custom = (builder
          .set_walls("concrete")
          .set_roof("flat")
          .set_floors(2)
          .add_garage()
          .add_extra("rooftop terrace")
          .build())
print(custom)
```

**Output:**
```
House:
  Walls  : wood
  Roof   : gabled
  Floors : 1
  Garage : no
  Pool   : no

House:
  Walls  : stone
  Roof   : terracotta
  Floors : 3
  Garage : yes
  Pool   : yes
  Garden : large
  Extras : home cinema, solar panels

House:
  Walls  : concrete
  Roof   : flat
  Floors : 2
  Garage : yes
  Extras : rooftop terrace
```

---

### Real-World Use Cases

| Domain | Example |
|---|---|
| **SQL query builders** | `query.select("*").from_("users").where("age > 18").limit(10).build()` |
| **HTTP request clients** | Building requests with headers, auth, body, timeout step by step |
| **Test data factories** | Creating complex test objects with only the fields relevant to each test |
| **Configuration objects** | App configs assembled from many optional sections |
| **Document generation** | Assembling PDF/HTML reports section by section |

---

### When to Use It

✅ The object has **many optional parameters** (avoids "telescoping constructors")
✅ You need **different representations** of the same construction process
✅ You want **immutable** products but a flexible construction process
✅ Construction involves **validation logic** between steps

### When NOT to Use It

❌ The object is simple with only a few required fields — a plain constructor or `dataclass` is cleaner
❌ You only ever need one configuration — the pattern adds boilerplate for no gain