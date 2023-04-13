input="cluster_scripts/Parameters.txt"
while IFS= read -r line
do
  bash cluster_scripts/BashStochastic.sh $line
done < "$input"
