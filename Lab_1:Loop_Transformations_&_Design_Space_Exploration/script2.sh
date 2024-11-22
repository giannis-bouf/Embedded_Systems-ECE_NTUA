#!/bin/bash

start_time=$(date +%s)

python3 genOptimizer.py

end_time=$(date +%s)
total_time=$((end_time - start_time))
echo "Total time for exhaustive search: ${total_time} seconds"
