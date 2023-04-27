#!/bin/bash

#SBATCH --job-name=MAR 		                 #Name of the job
#SBATCH --nodes=1				                   #Required nodes, Default=1
#SBATCH --ntasks-per-node=1				         #Tasks per node
#SBATCH --cpus-per-task=1		               #Cores per task
#SBATCH --mem=65536		                    #Memory in Mb per CPU
#SBATCH --mail-user=ramirez@mis.mpg.de
#SBATCH --mail-type=FAIL                  #Send email at BEGIN, END, FAIL, REQUEUE, ALL

input="cluster_scripts/Parameters.txt"
while IFS= read -r line
do
  module load julia/1.8.5
    julia --project=. scripts/StochasticRun.jl $line
    julia --project=. scripts/GraphsRun.jl $line
    julia --project=. scripts/QuantifiersRun.jl $line
  module unload julia/1.8.5
done < "$input"
