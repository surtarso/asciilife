# core/init.sh

# Grid setup and initial seeding

declare -A alive sym col repro move_ch age max_age energy predator food food_age terrain
declare -A n_alive n_sym n_col n_repro n_move_ch n_age n_max_age n_energy n_predator n_food
declare -a alive_list

grid_size=0  # will be set in asciilife.sh after terminal size known

seed_initial() {
  # Seed water terrain first
  local initial_water=$(( grid_size * WATER_PCT / 100 ))
  local placed_water=0
  while (( placed_water < initial_water )); do
    local idx=$(rand "$grid_size")
    if (( terrain[$idx] == 0 )); then
      terrain[$idx]=1
      (( placed_water++ ))
    fi
  done

  # Seed initial food on non-water tiles
  local initial_food=$(( grid_size / FOOD_START_RATIO ))  # roughly 12.5% of tiles start as food
  local placed_food=0
  while (( placed_food < initial_food )); do
    local idx=$(rand "$grid_size")
    if (( terrain[$idx] == 0 && food[$idx] == 0 )); then
      food[$idx]=1
      food_age[$idx]=$(randi 0 $((FOOD_MAX_AGE / 2)))  # some young, some older
      (( placed_food++ ))
    fi
  done

  # Seed initial population on non-water tiles
  local placed=0
  while (( placed < INIT_POPULATION )); do
    local x=$(rand $GRID_W)
    local y=$(rand $GRID_H)
    local i=$(( y * GRID_W + x ))
    if (( terrain[$i] == 0 && alive[$i] == 0 )); then
      alive[$i]=1
      sym[$i]="${SYMBOLS[$(rand ${#SYMBOLS[@]})]}"
      col[$i]="${COLORS[$(rand ${#COLORS[@]})]}"
      repro[$i]="$(randi $MIN_REPRO $MAX_REPRO)"
      move_ch[$i]="$(randi $MIN_MOVE $MAX_MOVE)"
      age[$i]=0
      max_age[$i]="$(randi $MIN_AGE $MAX_AGE)"
      energy[$i]=$ENERGY_START
      if (( $(rand 100) < PREDATOR_CHANCE )); then
        predator[$i]=1
        sym[$i]="${PREDATOR_SYMBOL[$(rand ${#PREDATOR_SYMBOL[@]})]}"
        # sym[$i]=$PREDATOR_SYMBOL
        col[$i]=$PREDATOR_COLOR
      else
        predator[$i]=0
        col[$i]="${COLORS[$(rand ${#COLORS[@]})]}"
      fi
      (( placed++ ))
      alive_list+=("$i")
    fi
  done
}