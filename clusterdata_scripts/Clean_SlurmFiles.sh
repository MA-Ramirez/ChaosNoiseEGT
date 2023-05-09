# Removes slurm-*.out files in all *_Chaos folders
for i in *_Chaos;
do 
	cd $i/ChaosNoiseEGT/
	rm slurm* 
	cd ../.. 
done
