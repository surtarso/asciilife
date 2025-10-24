# core/init.sh

# Grid setup and initial seeding

declare -A alive sym col repro move_ch age max_age energy predator food
declare -A n_alive n_sym n_col n_repro n_move_ch n_age n_max_age n_energy n_predator n_food
declare -a alive_list

grid_size=0  # will be set in asciilife.sh after terminal size known

seed_initial() {
  local placed=0
  while (( placed < INIT_POPULATION )); do
    local x=$(rand $GRID_W)
    local y=$(rand $GRID_H)
    local i=$(( y * GRID_W + x ))
    if (( alive[$i] == 0 )); then
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

  # --- Seed initial food ---
  # Start with a baseline amount of food across the map
  local initial_food=$(( grid_size / FOOD_START_RATIO ))  # roughly 12.5% of tiles start as food
  for ((n=0; n<initial_food; n++)); do
    local idx=$(rand "$grid_size")
    food[$idx]=1
    food_age[$idx]=$(randi 0 $((FOOD_MAX_AGE / 2)))  # some young, some older
  done
}
