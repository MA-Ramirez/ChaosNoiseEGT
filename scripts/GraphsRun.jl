"""
Script used to graph the solution of the ODEs that is saved in the data folder.
A ternary plot and a timeseries plot (general and with zoom) is generated.
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

include(srcdir("Graphs.jl"))

################################################################################
#                                   Import data                                #
################################################################################

#Check correct input of parameters
num_arguments = size(ARGS)[1]
if num_arguments == 1
    APPROACH = "Deterministic"
elseif num_arguments == 2
    APPROACH = "Stochastic"
else
    throw(ArgumentError("There should be 3 command line arguments, but there are "*string(num_arguments)))
end

#Obtain arguments and define them as global variables
B = ARGS[1]
if num_arguments == 2
    N = ARGS[2]
end

#From arguments define the name of the file to read
if APPROACH == "Deterministic"
    NAMEFILE = "Det_B="*B*".txt"
elseif APPROACH == "Stochastic"
    NAMEFILE = "Sto_B="*B*"_N="*N*".txt"
end

################################################################################
#                                  Graph plots                                 #
################################################################################


X1,X2,X3,X4 = getdata(APPROACH,NAMEFILE)
ternary_plot_save(APPROACH,NAMEFILE,X1,X2,X3)
timeseries_save(APPROACH,NAMEFILE,X1,X2,X3,X4)
timeseries_zoom_save(APPROACH,NAMEFILE,X1,X2,X3,X4)
