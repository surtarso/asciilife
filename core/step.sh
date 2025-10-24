# core/step.sh

# --- Brain of life ticks ---
# Reproduction rules
# Movement rules
# Energy metabolism
# Predator-prey interactions
# Aging & death

# --- Main tick update ---
step() {
  # start with fresh next-state copies (clear)
  n_alive=()
  n_sym=()
  n_col=()
  n_repro=()
  n_move_ch=()
  n_age=()
  n_max_age=()
  n_energy=()
  n_predator=()

  # iterate all current cells
#   for ((i=0;i<grid_size;i++)); do
    for i in "${alive_list[@]}"; do
    if (( alive[$i] == 1 )); then
      # Copy by default if nothing else happens
      local cur_sym=${sym[$i]}
      local cur_col=${col[$i]}
      local cur_repro=${repro[$i]}
      local cur_move=${move_ch[$i]}
      local cur_age=${age[$i]}
      local cur_max=${max_age[$i]}
      local cur_energy=${energy[$i]}
      local cur_pred=${predator[$i]}


      # 1) Age and check death by old age
      cur_age=$(( cur_age + 1 ))
      local died=0
      if (( cur_age >= cur_max )); then
        died=1
      fi

      # Energy drain each tick
      cur_energy=$(( cur_energy - ENERGY_IDLE_COST ))
      if (( cur_energy <= 0 )); then
        died=1
      fi

      # Adjust movement chance based on day/night and type
        if (( cur_pred == 0 )); then
            # Herbivores move more during the day
            if (( IS_DAY==1 )); then
                cur_move=$(( cur_move + HERBIVOR_SPEED_DAY ))  # boost movement during day
            else
                cur_move=$(( cur_move - HERBIVOR_SPEED_NIGHT ))  # slower at night
            fi
        else
            # Predators move more at night
            if (( IS_DAY==0 )); then
                cur_move=$(( cur_move + PREDATOR_SPEED_NIGHT ))  # boost movement at night
            else
                cur_move=$(( cur_move - PREDATOR_SPEED_DAY ))  # slower during day
            fi
        fi

        # Terrain penalty
        if (( $(has_water_neighbor "$i") == 1 )); then
          cur_move=$(( cur_move - WATER_MOVE_CHANCE_PENALTY ))
        fi

        # clamp move chance to 1..100
        (( cur_move < 1 )) && cur_move=1
        (( cur_move > 100 )) && cur_move=100

      # 2) Movement: attempt to move to an empty neighbor
      local moved=0
      if (( died == 0 )) && (( $(rand 100) < cur_move )); then
        target=$(choose_empty_neighbor "$i")
        if (( target >= 0 )); then
          n_alive[$target]=1
          n_sym[$target]="$cur_sym"
          n_col[$target]="$cur_col"
          n_repro[$target]="$cur_repro"
          n_move_ch[$target]="$cur_move"
          n_age[$target]="$cur_age"
          n_max_age[$target]="$cur_max"
          n_energy[$target]="$cur_energy"
          n_predator[$target]="$cur_pred"
          moved=1
          cur_energy=$(( cur_energy - ENERGY_MOVE_COST ))
          if (( cur_energy <= 0 )); then died=1; fi
        fi
      fi

      # 2.4) Herbivores eat food on their tile
      if (( died == 0 && cur_pred == 0 && food[$i] == 1 )); then
            if (( IS_DAY == 1 )); then
                cur_energy=$(( cur_energy + ENERGY_EAT_GAIN )) # eat more efficiently during day
            else
                cur_energy=$(( cur_energy + ENERGY_EAT_GAIN / 2 )) # less efficient at night
            fi
            (( cur_energy > ENERGY_MAX )) && cur_energy=$ENERGY_MAX
            food[$i]=0
        fi


      # 2.5) Predation - eat adjacent prey
      if (( died == 0 && cur_pred == 1 )); then
        for idxn in $(neighbors "$i"); do
          if (( alive[$idxn]==1 )); then
            if (( predator[$idxn]==0 )); then
              # predator eats prey
              cur_energy=$(( cur_energy + ENERGY_EAT_GAIN ))
              if (( cur_energy > ENERGY_MAX )); then cur_energy=$ENERGY_MAX; fi
              # prey dies
              alive[$idxn]=0
              break
            fi
          fi
        done
      fi

      # 3) Reproduction: maybe create a child in an empty neighboring cell
      if (( died == 0 )) && (( cur_energy > ENERGY_REPRO_COST )) && (( $(rand 100) < cur_repro )); then
        cur_energy=$(( cur_energy - ENERGY_REPRO_COST ))
        child_pos=$(choose_empty_neighbor "$i")
        if (( child_pos >= 0 )); then
          # child's genome is a (possibly mutated) copy
          local child_repro=$(mutate_numeric "$cur_repro")
          
          if (( IS_DAY == 0 )); then
            cur_repro=$(( cur_repro * 2 ))  # raise reproduction at night
          fi
          # clamp child_repro to 1..100
          if (( child_repro < 1 )); then child_repro=1; fi
          if (( child_repro > 100 )); then child_repro=100; fi
          local child_move=$(mutate_numeric "$cur_move")
          if (( child_move < 1 )); then child_move=1; fi
          if (( child_move > 100 )); then child_move=100; fi
          local child_max=$(mutate_numeric "$cur_max")
          if (( child_max < 2 )); then child_max=2; fi

          local child_sym=$(mutate_symbol "$cur_sym")
          local child_col=$(mutate_color "$cur_col")

          # Place child in next state; ensure we don't overwrite an existing placement
          if (( n_alive[$child_pos] != 1 )); then
            n_alive[$child_pos]=1
            n_sym[$child_pos]="$child_sym"
            n_col[$child_pos]="$child_col"
            n_repro[$child_pos]="$child_repro"
            n_move_ch[$child_pos]="$child_move"
            n_age[$child_pos]=0
            n_max_age[$child_pos]="$child_max"
            n_energy[$child_pos]="$cur_energy"
            n_predator[$child_pos]="$cur_pred"
          fi
        fi
      fi

      # 4) If didn't move and didn't die, remain at same position in next state
      if (( died == 0 )) && (( moved == 0 )); then
        if (( n_alive[$i] != 1 )); then
          n_alive[$i]=1
          n_sym[$i]="$cur_sym"
          n_col[$i]="$cur_col"
          n_repro[$i]="$cur_repro"
          n_move_ch[$i]="$cur_move"
          n_age[$i]="$cur_age"
          n_max_age[$i]="$cur_max"
          n_energy[$i]="$cur_energy"
          n_predator[$i]="$cur_pred"
        else
          # cell already occupied in next state (collision): simple resolution:
          # keep whichever occupant has higher repro chance
          local other_repro=${n_repro[$i]}
          if (( cur_repro > other_repro )); then
            n_sym[$i]="$cur_sym"
            n_col[$i]="$cur_col"
            n_repro[$i]="$cur_repro"
            n_move_ch[$i]="$cur_move"
            n_age[$i]="$cur_age"
            n_max_age[$i]="$cur_max"
            n_energy[$i]="$cur_energy"
            n_predator[$i]="$cur_pred"
          fi
        fi
      fi
      # if died -> nothing copied to next state
    fi
  done

  # commit next state to current arrays
  alive=()
  sym=()
  col=()
  repro=()
  move_ch=()
  age=()
  max_age=()
  energy=()
  predator=()
  alive_list=()  # Rebuild the active list fresh each tick

  for i in "${!n_alive[@]}"; do
    alive[$i]=1
    sym[$i]="${n_sym[$i]}"
    col[$i]="${n_col[$i]}"
    repro[$i]="${n_repro[$i]}"
    move_ch[$i]="${n_move_ch[$i]}"
    age[$i]="${n_age[$i]}"
    max_age[$i]="${n_max_age[$i]}"
    energy[$i]="${n_energy[$i]}"
    predator[$i]="${n_predator[$i]}"
    alive_list+=("$i")  # Add to active list for next tick
  done

  # --- Food lifecycle & regrow ---
  if (( IS_DAY==1 )); then
     # day: more food spawn
    FOOD_REPRO_RATE_DAY=$(( FOOD_REPRO_RATE + FOOD_DAY_BOOST ))
  else
    # night: reproduction stops, maybe animals reproduce more
    FOOD_REPRO_RATE_DAY=$FOOD_REPRO_RATE
  fi

  for ((i=0;i<grid_size;i++)); do
    if (( food[$i]==1 )); then
        (( food_age[$i]++ ))
        # natural death of food
        if (( food_age[$i] >= FOOD_MAX_AGE )); then
        food[$i]=0
        food_age[$i]=0
        else
        # chance to reproduce nearby
        local current_rate=$FOOD_REPRO_RATE_DAY
        if (( $(has_water_neighbor "$i") == 1 )); then
          current_rate=$(( current_rate + FOOD_WATER_BOOST ))
        fi
        if (( $(rand 100) < current_rate )); then
            target=$(choose_empty_neighbor "$i")
            if (( target >= 0 )); then
            food[$target]=1
            food_age[$target]=0
            fi
        fi
        fi
    fi
  done


  ((TICK_COUNT++))
  if (( TICK_COUNT % DAY_LENGTH == 0 )); then
      IS_DAY=$((1 - IS_DAY))
  fi
}