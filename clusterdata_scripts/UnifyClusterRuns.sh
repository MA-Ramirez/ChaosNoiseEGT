for i in *_Chaos;
do
	cd $i/ChaosNoiseEGT/data/Quantifiers/QuantifiersSto/
	cat Sto_FD.csv >> ../../../../../unified_FD.csv
	cat Sto_FixT.csv >> ../../../../../unified_FixT.csv
	cat Sto_LZ.csv >> ../../../../../unified_LZ.csv
	cat Sto_Std.csv >> ../../../../../unified_Std.csv
	cd ../../../../..
done
