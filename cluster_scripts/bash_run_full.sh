input="cluster_scripts/Parameters.txt"
while IFS= read -r line
do
  julia scripts/StochasticRun.jl $line
  julia scripts/GraphsRun.jl $line
  julia scripts/QuantifiersRun.jl $line
done < "$input"