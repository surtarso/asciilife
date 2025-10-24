# utils/rand.sh

# RNG helpers
# How randomness works

# RNG helper: returns 0..(n-1)
rand() { local n=$1; (( n <= 0 )) && n=1; echo $(( RANDOM % n )); }

# Return random integer between a and b inclusive
randi() { local a=$1 b=$2; (( b < a )) && b=$a; echo $(( a + RANDOM % (b - a + 1) )); }
