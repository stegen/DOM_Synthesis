#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=step3P
#SBATCH --mail-type=END
#SBATCH --mail-user=klongnecker@whoi.edu
#SBATCH --ntasks=1
#SBATCH --mem=4000
#SBATCH --time=0:30:00
#SBATCH --output=/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/logfiles_dir/step3P.out
#SBATCH --error=/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/logfiles_dir/step3P.error
 
dir="$HOME/DOM_Synthesis/transformations_HPC"
cd "$dir"

log_dir="$dir/logfiles_dir_P" #need a folder to hold the output results text files - there are zillions of them. 

echo `date`
echo This is job $SLURM_JOB_ID
echo This is task $SLURM_ARRAY_TASK_ID

CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
conda activate tformsKL1

#Rscript --no-save --no-restore --verbose $dir/scripts_dir/tforms_parallel_step3.R "$out_dir_summary" "$dir"> "$log_dir/${SLURM_JOB_NAME}.Rout" 2>&1 > "$log_dir/${SLURM_JOB_NAME}.log"
#cheat - hard code in the folder names and not pass them as variables
Rscript --no-save --no-restore --verbose $dir/scripts_dir/tforms_parallel_step3.R > "$log_dir/${SLURM_JOB_NAME}.Rout" 2>&1 > "$log_dir/${SLURM_JOB_NAME}.log"
echo `date`
