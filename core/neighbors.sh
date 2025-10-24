# core/neighbors.sh

# Neighbor finding, distance logic, spatial checks.

neighbors() {
  local i=$1 x=$(( i % GRID_W )) y=$(( i / GRID_W )) nx ny idxn
  for dy in -1 0 1; do
    for dx in -1 0 1; do
      (( dx==0 && dy==0 )) && continue
      nx=$(( (x + dx + GRID_W) % GRID_W ))
      ny=$(( (y + dy + GRID_H) % GRID_H ))
      idxn=$(( ny * GRID_W + nx ))
      echo -n "$idxn "
    done
  done
}

choose_empty_neighbor() {
  local i=$1 nlist=( $(neighbors "$i") ) empties=()
  for idxn in "${nlist[@]}"; do
    (( alive[$idxn]==0 && n_alive[$idxn]==0 && terrain[$idxn]!=1 )) && empties+=( "$idxn" )
  done
  (( ${#empties[@]} == 0 )) && echo -1 || echo "${empties[$(rand ${#empties[@]})]}"
}

has_water_neighbor() {
  local i=$1 nlist=( $(neighbors "$i") ) has_water=0
  for idxn in "${nlist[@]}"; do
    if (( terrain[$idxn] == 1 )); then
      has_water=1
      break
    fi
  done
  echo "$has_water"
}