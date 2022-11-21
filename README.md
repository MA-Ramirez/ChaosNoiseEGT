# ChaosNoiseEGT

## Overview
The code allows the evolution of a system using the pairwise comparison process.
Given any payoff matrix defined in `src/PayoffMatrix.jl`, the system can be evolved through a deterministic or a stochastic approach.

### 1. Deterministic approach
The deterministic approach is based on solving a set of differential equations (see eqs paper).
The main parameter of this approach is the selection intensity coefficient (`B`).

-To solve the set of equations and obtain the data: `julia scripts/DeterministicRun.jl B`

-To graph the data (ternary plot and timeseries): `julia scripts/GraphsRun.jl B`

-To measure the quantifiers used to characterise the dynamics: `julia scripts/QuantifiersRun.jl B`

### 2. Stochastic approach
The stochastic approach is based on simulating the stochastic process.
The main parameters of this approach are the selection intensity coefficient (`B`) and the population size (`N`).

-To simulate the process and obtain the data: `julia scripts/StochasticRun.jl B`

-To graph the data (ternary plot and timeseries): `julia scripts/GraphsRun.jl B`

-To measure the quantifiers used to characterise the dynamics: `julia scripts/QuantifiersRun.jl B`

#### 2.1 Cluster runs
To get an accurate interpretation of the stochastic simulation results, it is required to run several runs.

-To set the parameters to be explored: 

-To run the simulations in the cluster:

-To obtain the main statistical measures of the results:

-To graph the results:

## Reproducibility
This code base is using the Julia Language and [DrWatson](https://juliadynamics.github.io/DrWatson.jl/stable/)
to make a reproducible scientific project named
> ChaosNoiseEGT

It is authored by Maria Alejandra Ramirez.

To (locally) reproduce this project, do the following:

0. Download this code base. Notice that raw data are typically not included in the
   git-history and may need to be downloaded independently.
1. Open a Julia console and do:
   ```
   julia> using Pkg
   julia> Pkg.add("DrWatson") # install globally, for using `quickactivate`
   julia> Pkg.activate("path/to/this/project")
   julia> Pkg.instantiate()
   ```

This will install all necessary packages for you to be able to run the scripts and
everything should work out of the box, including correctly finding local paths.

Note: to graph the ternary plots it is required to download the python package [mpltern](https://mpltern.readthedocs.io/en/latest/installation.html)
