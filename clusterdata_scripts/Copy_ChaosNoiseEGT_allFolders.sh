# Copies ChaosNoiseEGT folder to all the *_Chaos folders
# It only overwrites changed files, without modifying/deleting other files
for i in *_Chaos;
do 
	cp -r ChaosNoiseEGT/ $i
done
