#!/bin/bash

output_file="results.csv"
echo "Output File: ${output_file}"
echo "L1D,L1I,L2,Unrolling,Cycles" > $output_file

l1d_sizes=("2kB" "4kB" "8kB" "16kB" "32kB" "64kB")
l1i_sizes=("2kB" "4kB" "8kB" "16kB" "32kB" "64kB")
l2_sizes=("128kB" "256kB" "512kB" "1024kB")
unrolling_factors=("2" "4" "8" "16" "32")

start_time=$(date +%s)
echo "Start Time: ${start_time}"

for l1d in "${l1d_sizes[@]}"; do
  for l1i in "${l1i_sizes[@]}"; do
    for l2 in "${l2_sizes[@]}"; do
      for unroll in "${unrolling_factors[@]}"; do
        
        build/X86/gem5.opt configs/learning_gem5/part1/two_level.py \
        /gem5/tables_UF/tables_uf${unroll}.exe --l1i_size=${l1i} \
        --l1d_size=${l1d} --l2_size=${l2}
        
        cycles=$(grep "system.cpu.numCycles" ./m5out/stats.txt | awk '{print $2}')
        
        echo "${l1d},${l1i},${l2},${unroll},${cycles}" >> $output_file
        
      done
    done
  done
done

end_time=$(date +%s)
total_time=$((end_time - start_time))
echo "Total time for exhaustive search: ${total_time} seconds"
