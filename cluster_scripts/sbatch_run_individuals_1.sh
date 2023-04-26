input="cluster_scripts/Parameters.txt"
while IFS= read -r line
do
  sbatch cluster_scripts/sbatch_run_individuals_2.sh $line
done < "$input"
