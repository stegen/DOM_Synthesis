#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=step1
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=klongnecker@whoi.edu
#SBATCH --ntasks=1
#SBATCH --mem=4000
#SBATCH --time=0:30:00
#SBATCH --output=/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/logfiles_dir/step1.out
#SBATCH --error=/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/logfiles_dir/step1.error
 
dir="$HOME/DOM_Synthesis/transformations_HPC"
cd "$dir"

#in_dir="/vortexfs1/omics/kujawinski/data/DOMsynthesis"
#out_dir="$dir/output_dir"
log_dir="$dir/logfiles_dir" #need a folder to hold the output results text files - there are zillions of them. 

if [ ! -d "$out_dir" ]; then
    mkdir -p "$out_dir"
fi
if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
fi

echo `date`
echo This is job $SLURM_JOB_ID
echo This is task $SLURM_ARRAY_TASK_ID

CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
conda activate tformsKL1

#Rscript --no-save --no-restore --verbose $dir/scripts_dir/tforms1.R "$in_dir" "$out_dir" > "$log_dir/${SLURM_JOB_NAME}.Rout" 2>&1 > "$log_dir/${SLURM_JOB_NAME}.log"
Rscript --no-save --no-restore --verbose $dir/scripts_dir/tforms1.R > "$log_dir/${SLURM_JOB_NAME}.Rout" 2>&1 > "$log_dir/${SLURM_JOB_NAME}.log"
echo `date`
