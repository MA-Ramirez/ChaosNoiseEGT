# It runs the sbatch_run_individuals_1.sh in the cluster for all *_Chaos folders
for i in *_Chaos;
do 
	cd $i/ChaosNoiseEGT/
	bash cluster_scripts/sbatch_run_individuals_1.sh 
	cd ../..
done
