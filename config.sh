# config.sh

# Simulation parameters
TICK_SLEEP=0.12
INIT_POPULATION=40
MUTATION_RATE=8
MUTATION_MAG=20
MIN_REPRO=10
MAX_REPRO=70
MIN_MOVE=10
MAX_MOVE=80
MIN_AGE=1
MAX_AGE=50

# Metabolism & energy
ENERGY_START=50
ENERGY_MAX=100
ENERGY_MOVE_COST=2
ENERGY_IDLE_COST=1
ENERGY_REPRO_COST=20
ENERGY_EAT_GAIN=20
REPRO_NIGHT_BOOST=15   # Additive percentage to reproduction chance at night

# Herbivores
HERBIVOR_SPEED_DAY=10    # adds to normal speed (cur_move + HERBIVOR_SPEED_DAY)
HERBIVOR_SPEED_NIGHT=10  # subtracts from normal speed (cur_move - HERBIVOR_SPEED_NIGHT)
# SYMBOLS=("🐇" "🐄" "🐐" "🐑" "🦌" "🦙")
SYMBOLS=("Ø" "©" "ø" "ð" "®")
COLORS=(33 35 36 37 38)
MUTATE_PREDATOR_CHANCE=1

# Predation
PREDATOR_SPEED_DAY=10     # subtracts to normal speed (cur_move - PREDATOR_SPEED_DAY)
PREDATOR_SPEED_NIGHT=15   # adds from normal speed (cur_move + PREDATOR_SPEED_NIGHT)
PREDATOR_CHANCE=15
PREDATOR_COLOR=31
PREDATOR_SYMBOL=("«" "»")
# PREDATOR_SYMBOL=("🐺")

# Food parameters
FOOD_START_RATIO=8       # roughly 12.5% of tiles start as food (lower=more)
FOOD_MAX_AGE=36
FOOD_REPRO_RATE=2
FOOD_DAY_BOOST=5
FOOD_WATER_BOOST=3
FOOD_COLOR=32
FOOD_SYMBOL="°"
# FOOD_SYMBOL="🌿"

# Terrain parameters (unused)
WATER_PCT=1              # Percentage of grid as water (adjust for density)
WATER_SYMBOL="~"         # Visual for water
WATER_COLOR=34           # Blue ANSI color
WATER_MOVE_CHANCE_PENALTY=15 # Penalty to movement chance near water

# Day/Night
DAY_LENGTH=24
IS_DAY=1
TICK_COUNT=0
