input="cluster_scripts/Parameters.txt"
while IFS= read -r line
do
  julia --project=. scripts/StochasticRun.jl $line
  julia --project=. scripts/GraphsRun.jl $line
  julia --project=. scripts/QuantifiersRun.jl $line
done < "$input"