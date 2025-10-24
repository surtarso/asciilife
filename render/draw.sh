# render/draw.sh

# --- How the world looks ---
# New symbols/colors
# Special effects like blinking, highlights, or info overlay
# Debug info

# --- Rendering function ---
draw() {
  # move to top-left
  tput cup 0 0
  local row out i ch ccode
  for ((y=0; y<GRID_H; y++)); do
    out=""
    for ((x=0; x<GRID_W; x++)); do
      i=$(( y * GRID_W + x ))
      if (( alive[$i] == 1 )); then
        ch="${sym[$i]}"
        ccode="${col[$i]}"
        # blinking wont work on this speeds
        # blink=""
        # if (( energy[$i] < ENERGY_MAX / 5 )); then
        #   blink=";5"  # ANSI blink
        # fi
        # Add color escape and character
        out+=$'\033['"${ccode}"'m'"${ch}"$'\033[0m'
      elif (( food[$i] == 1 )); then
        out+=$'\033['"${FOOD_COLOR}"'m'"${FOOD_SYMBOL}"$'\033[0m'
      elif (( terrain[$i] == 1 )); then
        out+=$'\033['"${WATER_COLOR}"'m'"${WATER_SYMBOL}"$'\033[0m'
      else
        out+=" " # empty space
      fi
    done
    printf '%s\n' "$out"
  done

  # footer info line
  # count population and stats
  local pop=0 avg_rep=0 avg_move=0 oldest=0
  for ((i=0;i<grid_size;i++)); do
    if (( alive[$i]==1 )); then
      (( pop++ ))
      (( avg_rep += repro[$i] ))
      (( avg_move += move_ch[$i] ))
      if (( max_age[$i] > oldest )); then oldest=${max_age[$i]}; fi
    fi
  done
  if (( pop > 0 )); then
    avg_rep=$(( avg_rep / pop ))
    avg_move=$(( avg_move / pop ))
  else
    avg_rep=0; avg_move=0
  fi
  # Print stats
    local cycle="Day"; if (( IS_DAY==0 )); then cycle="Night"; fi
   printf 'Population: %3d  Love: %3d%%  Roam: %3d%%  MaxAge: %2d  Cycle: %s  Heartbeat: %d  \r' \
    "$pop" "$avg_rep" "$avg_move" "$oldest" "$cycle" "$TICK_COUNT"
}