#!/usr/bin/bash

screen -dmS fuzzer1 /usr/bin/bash -c "afl-fuzz -i afl_in -o afl_out -M fuzzer1 -- ./binary @@"
screen -dmS fuzzer2 /usr/bin/bash -c "afl-fuzz -i afl_in -o afl_out -S fuzzer2 -- ./binary @@"
screen -dmS fuzzer3 /usr/bin/bash -c "afl-fuzz -i afl_in -o afl_out -S fuzzer3 -- ./binary @@"
screen -dmS fuzzer4 /usr/bin/bash -c "afl-fuzz -i afl_in -o afl_out -S fuzzer3 -- ./binary @@"
