# It unifies the stochastic quantifiers results from all *_Chaos folders under a single .csv file
for i in *_Chaos;
do
	cd $i/ChaosNoiseEGT/data/Quantifiers/QuantifiersSto/
	cat Sto_FD.csv >> ../../../../../unified_FD.csv
	cat Sto_FixT.csv >> ../../../../../unified_FixT.csv
	cat Sto_LZ.csv >> ../../../../../unified_LZ.csv
	cat Sto_Std.csv >> ../../../../../unified_Std.csv
	cat Sto_PE.csv >> ../../../../../unified_PE.csv
	cd ../../../../..
done
