# DOM_Synthesis
DOM synthesis working group

Start a README.md file to track activities as they are done.
## 25 October 2023
Copying the trimmed data to WHOI's HPC server / poseidon. Will set up the transformations script from James to run on the HPC.

## Create the conda environment you will need
You use conda to gather all the pieces you need: R and its various packages. 
For example, I needed R version 4.21 (or so) which required updating my YML file. 
This is quite a process (read, hassle). To do this, you need to set up a conda environment, install all the packages in that environment, and export the yml file to use in the future. 
Here's the steps that worked for me (after logging into Poseidon):\
```module load anaconda/5.1```\
```conda config --add channels conda-forge``` (you cannot get R>3.6 from anaconda)\
```conda config --set channel_priority strict``` (may not be necessary)\
```conda search r-base``` (find the packages)\
```conda create -n r_4.2.0``` (make the environment first, otherwise this hangs forever)\
```conda activate r_4.2.0``` (activate it, nothing there yet)\
```conda install -c conda-forge r-base=4.2.0```\
```conda install r-essentials``` \
```conda install r-gtools```\
```conda env export > tformsKL1.yml``` 

At this point you have your configuration file (the yml file), edit it *locally* to change the environment to be tformsKL1 --> do this by setting the first row to ```name: tformsKL1``` and at the very end of the file, edit this ```prefix: /vortexfs1/home/klongnecker/.conda/envs/tforms1KL4```. Then, go into the various slurm scripts which follow and change them all to read ```conda activate tformsKL1```. After the local editing, put the new yml file on the HPC.

Install the conda environment via the yml file:\
```conda env create --file tformsKL1.yml```

You only have to create the environment once, anytime you want it in the future, just activate it:
```conda activate tformsKL1```

Remember that each sbatch command creates a new compute environment, so all the slurm scripts all have this statement in them: ```conda activate tformsKL1``` where tformsKL1 is the name established by the yml file above. Also remember that you have activate the module with conda before doing anything (see above in the step about accessing Poseidon, repeating here because I keep forgetting).

## Misc. handy functions
```conda info --envs```\
```conda search r-base```\
```squeue -u klongnecker```

This will let you open up an R window for testing on Poseidon (useful for testing):\
```srun -p compute --time=01:00:00 --ntasks-per-node=1 --mem=10gb --pty bash```\
```conda activate tformsKL1```\
```R```\
```source("create_xset.R")``` (for example - could run the create_xset.R script)



