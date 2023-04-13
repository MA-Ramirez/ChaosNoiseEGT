input="cluster_scripts/Parameters.txt"
while IFS= read -r line
do
  sbatch cluster_scripts/SbatchStochastic.sh $line
done < "$input"
