# core/mutate.sh

# How traits mutate

mutate_numeric() {
  local val=$1
  if (( $(rand 100) < MUTATION_RATE )); then
    local change=$(randi $((-MUTATION_MAG)) $MUTATION_MAG)
    local new=$(( val + (val * change) / 100 ))
    (( new < 1 )) && new=1
    echo "$new"
  else
    echo "$val"
  fi
}

mutate_symbol() {
  local s=$1
  (( $(rand 100) < MUTATION_RATE )) && echo "${SYMBOLS[$(rand ${#SYMBOLS[@]})]}" || echo "$s"
}

mutate_color() {
  local c=$1
  (( $(rand 100) < MUTATION_RATE )) && echo "${COLORS[$(rand ${#COLORS[@]})]}" || echo "$c"
}

mutate_predator() {
  local p=$1 # current predator status (0 or 1)
  local MUTATE_PREDATOR_CHANCE=1 # Small chance to flip type
  if (( $(rand 100) < MUTATE_PREDATOR_CHANCE )); then
    local new_p=$(( 1 - p ))
    echo "$new_p"
  else
    echo "$p"
  fi
}