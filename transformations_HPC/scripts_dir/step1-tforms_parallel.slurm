#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=step1P
#SBATCH --mail-type=END
#SBATCH --mail-user=klongnecker@whoi.edu
#SBATCH --ntasks=1
#SBATCH --mem=4000
#SBATCH --time=4:30:00
#SBATCH --output=/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/logfiles_dir/step1P.out
#SBATCH --error=/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/logfiles_dir/step1P.error
 
dir="$HOME/DOM_Synthesis/transformations_HPC"
cd "$dir"

in_dir="/vortexfs1/omics/kujawinski/data/DOMsynthesis"
out_dir="$dir/output_dir_P/"
log_dir="$dir/logfiles_dir_P" #need a folder to hold the output results text files - there are zillions of them. 

#need to make the directories that will be used
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

Rscript --no-save --no-restore --verbose $dir/scripts_dir/tforms_parallel_step1.R "$in_dir" "$out_dir" > "$log_dir/${SLURM_JOB_NAME}.Rout" 2>&1 > "$log_dir/${SLURM_JOB_NAME}.log"
echo `date`
