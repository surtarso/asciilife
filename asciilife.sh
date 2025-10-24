#!/usr/bin/env bash
# asciilife.sh
# Life sim in pure bash by Tarso Galvão 10/2025

# --- Glue and loop control ---

BASE_DIR="$(dirname "$0")"

# --- Configuration ---
source "$BASE_DIR/config.sh"

# --- Utilities ---
source "$BASE_DIR/utils/rand.sh"

# --- Cleanup function ---
cleanup_and_exit() {
  tput cnorm   # show cursor
  stty sane
  tput sgr0
  echo
  exit 0
}

# --- Trap for clean exit ---
trap 'cleanup_and_exit' INT TERM EXIT

# --- Core ---
source "$BASE_DIR/core/init.sh"
source "$BASE_DIR/core/mutate.sh"
source "$BASE_DIR/core/neighbors.sh"
source "$BASE_DIR/core/step.sh"

# --- Rendering ---
source "$BASE_DIR/render/draw.sh"

# --- Terminal setup ---
get_term_size() {
  TERM_W=$(tput cols)
  TERM_H=$(tput lines)
  GRID_W=$TERM_W
  GRID_H=$(( TERM_H - 2 ))
  (( GRID_H<6 )) && GRID_H=6
  (( GRID_W<20 )) && GRID_W=20
  grid_size=$(( GRID_W * GRID_H ))
}
get_term_size

clear
tput civis
orig_stty=$(stty -g)
stty -echo -icanon time 0 min 0

# --- Seed initial population ---
seed_initial

# --- Main loop ---
main_loop() {
  local key paused=0
  while true; do
    # handle user input (non-blocking)
    if read -r -n1 -t 0.001 key 2>/dev/null; then
      [[ "$key" == "q" || "$key" == "Q" ]] && break
      [[ "$key" == "r" || "$key" == "R" ]] && {
        for ((i=0;i<grid_size;i++)); do alive[$i]=0; done
        seed_initial
      }
      [[ "$key" == "p" || "$key" == "P" ]] && {
        (( paused = 1 - paused ))
        if (( paused == 1 )); then
          tput cup $GRID_H 0
          printf "\033[1;33mPaused (press 'p' to resume)\033[0m\n"
        else
          clear  # Redraw on resume
          draw
        fi
      }
    fi

    if (( paused == 0 )); then
      # --- Simulation step & render ---
      step
      draw

      # --- Check for extinction ---
      local pop=0
      for ((i=0;i<grid_size;i++)); do
        (( alive[$i] == 1 )) && (( pop++ ))
      done

      if (( pop == 0 )); then
        tput cup $GRID_H 0
        printf "\033[1;31mASCII EXTINCTION! Reseeding...\033[0m\n"
        sleep 1
        for ((i=0;i<grid_size;i++)); do alive[$i]=0; done
        seed_initial
      fi

      sleep "$TICK_SLEEP"
    else
      sleep 0.1  # Light sleep while paused to check keys
    fi
  done
}

tput cup $GRID_H 0
printf "\033[1;32mASCII Life Simulator\033[0m\nInitial pop: %d in %dx%d grid.\nPress 'q' to quit, 'r' to reseed, 'p' to pause.\n" "$INIT_POPULATION" "$GRID_W" "$GRID_H" 
sleep 3
main_loop
cleanup_and_exit