# Calculate the chemical transformations
DOM synthesis working group\
Using James Stegen's code, and putting it onto WHOI's HPC to do the calculations.\
Krista Longnecker, Woods Hole Oceanographic Institution

Start a README.md file to track activities as they are done.
## 25 October 2023
Use WinSCP to copy the trimmed data to WHOI's HPC server / poseidon. 

#### Create the conda environment you will need
Use conda to gather all the pieces you need: R and its various packages. To do this, you need to set up a conda environment, install all the packages in that environment, and export the yml file to use in the future. 
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

Remember that each sbatch command creates a new compute environment, so all the slurm scripts all have this statement in them: ```conda activate tformsKL1``` where tformsKL1 is the name established by the yml file above. Also remember that you have activate the module with conda before doing anything (see above in the step about accessing Poseidon, repeat here as a reminder).

#### Get started --> do the calculations
Now make this do the calculations in parallel - take better advantage of the HPC\
```sbatch scripts_dir/step1-tforms_parallel.slurm```\
```sbatch scripts_dir/step2-tforms_parallel.slurm```\
```sbatch scripts_dir/step3-tforms_parallel.slurm```

#### Misc notes here for now:
Working here on poseidon:\
```/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/scripts_dir```

Also note that I now have two branches in this repository, where **main** has the version that works on the HPC and **loopVersion** has the first attempt at brute forcing and keeping the for loop. I can swap between the two when working locally using Git Bash as follows:\
```git checkout loopVersion```\
Then do stuff to loopVersion, and push back up using the standard set of commands:\
```git add -A```\
```git commit -am "Brief description goes here"```\
```git push```\
Then make sure I remember to go back to primarily working on the main branch:
```git checkout main```


#### Misc. handy functions (keep at end for use during troubleshooting)
```conda info --envs```\
```conda search r-base```\
```squeue -u klongnecker```\
```ls -1 | wc -l``` (count # of files in a folder)
```sacct --name=step3P```

How to find one file in a list:\
```fi <-"ManyFiles_MGC1903260_FTMS_Lakes_FJ_Sweden_43_112_01_22816.corems"```\
```which(samples.to.process==fi,arr.ind=TRUE)```

This will let you open up an R window for testing on Poseidon (useful for testing):\
```srun -p compute --time=01:00:00 --ntasks-per-node=1 --mem=10gb --pty bash```\
```conda activate tformsKL1```\
```R```\
```source("create_xset.R")``` (for example - could run the create_xset.R script)



