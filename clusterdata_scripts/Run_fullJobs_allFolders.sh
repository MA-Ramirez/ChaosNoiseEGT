# It runs the sbatch_run_full.sh in the cluster for all *_Chaos folders
for i in *_Chaos;
do 
	cd $i/ChaosNoiseEGT/
	sbatch cluster_scripts/sbatch_run_full.sh 
	cd ../.. 
done
