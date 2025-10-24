# ASCII Life Simulator

Autonomous ASCII life simulation written in pure Bash.  
Simulates organisms with traits, reproduction, movement, energy metabolism, and predation in a terminal grid. There's still a lot to add and performs poorly. This is just for fun, works as a screensaver (that uses ~10% CPU). Results differ drastically depending on terminal window size.

---

## File Structure

```
.
├── asciilife.sh       # Main entry point, runs the simulation
├── config.sh          # Configuration parameters and world rules
├── core               # Core logic scripts
│   ├── init.sh        # Grid initialization and population seeding
│   ├── mutate.sh      # Trait mutation logic
│   ├── neighbors.sh   # Neighbor detection functions
│   └── step.sh        # Main simulation tick logic
├── render
│   └── draw.sh        # Rendering ASCII grid and stats
└── utils
└── rand.sh        # Random number helpers
````

---

## Installation & Usage

1. Clone the repository:

```bash
git clone https://github.com/surtarso/asciilife.git
cd asciilife
````

2. Make the main script executable:

```bash
chmod +x asciilife.sh
```

3. Run the simulation:

```bash
./asciilife.sh
```

* Press `q` to quit.
* Press `r` to reseed a new population.

---

## Configuration (`config.sh`)

All simulation parameters are in `config.sh`. Key variables:

* **Simulation speed & population**

  * `TICK_SLEEP` — seconds between simulation steps.
  * `INIT_POPULATION` — number of organisms at start.

* **Traits**

  * `MUTATION_RATE` — chance (%) a trait mutates on reproduction.
  * `MUTATION_MAG` — maximum % change for numeric traits.
  * `MIN_REPRO` / `MAX_REPRO` — reproduction probability range (%).
  * `MIN_MOVE` / `MAX_MOVE` — movement probability range (%).
  * `MIN_AGE` / `MAX_AGE` — lifespan range in ticks.

* **Symbols & Colors**

  * `SYMBOLS` — array of ASCII symbols for organisms.
  * `COLORS` — array of ANSI color codes for organisms.
  * `PREDATOR_SYMBOL` / `PREDATOR_COLOR` — predator display.
  * `FOOD_SYMBOL` / `FOOD_COLOR` — plant display.

* **Energy & Metabolism**

  * `ENERGY_START`, `ENERGY_MAX` — initial and maximum energy.
  * `ENERGY_MOVE_COST`, `ENERGY_IDLE_COST`, `ENERGY_REPRO_COST`, `ENERGY_EAT_GAIN`.

* **Predation**

  * `PREDATOR_CHANCE` — percent chance an organism is born as predator.

* **Day/Night cycle**

  * `DAY_LENGTH` — ticks per day.
  * `IS_DAY` — starting cycle (1 = day, 0 = night).

---

## Core Logic

* `core/init.sh` — Initializes empty grid and seeds organisms.
* `core/mutate.sh` — Handles trait mutation.
* `core/neighbors.sh` — Calculates 8-neighbor toroidal wrap positions.
* `core/step.sh` — Processes each simulation tick:

  * Ageing and death
  * Movement
  * Eating (plants or prey)
  * Reproduction with mutation
  * Plant regrowth
  * Day/night toggling

---

## Rendering (`render/draw.sh`)

* Prints the grid row by row.
* Alive organisms colored by `COLORS`.
* Predators use `PREDATOR_SYMBOL` and `PREDATOR_COLOR`.
* Plants displayed using `FOOD_SYMBOL` and `FOOD_COLOR`.
* Footer shows:

  * Population count
  * Average reproduction/movement rates
  * Oldest lifespan
  * Current day/night cycle
  * Tick counter

---

## Utilities (`utils/rand.sh`)

* `rand(n)` — returns integer in `[0, n-1]`.
* `randi(a, b)` — returns integer in `[a, b]` inclusive.

---

## Adding Features

1. **Add variables in `config.sh`** — all configurable parameters should go here.
2. **Modify logic in `core/step.sh`** — implement new traits or behaviors.
3. **Update mutation in `core/mutate.sh`** if new numeric traits are added.
4. **Update `render/draw.sh`** to visually represent new traits or symbols.

