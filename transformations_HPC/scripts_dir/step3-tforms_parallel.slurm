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

in_dir="/vortexfs1/omics/kujawinski/data/DOMsynthesis"
out_dir="$dir/output_dir_P/"
out_dir_summary="$dir/output_dir_summary_P/"
log_dir="$dir/logfiles_dir_P" #need a folder to hold the output results text files - there are zillions of them. 

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

Rscript --no-save --no-restore --verbose $dir/scripts_dir/tforms_parallel_step3.R "$out_dir_summary" > "$log_dir/${SLURM_JOB_NAME}.Rout" 2>&1 > "$log_dir/${SLURM_JOB_NAME}.log"
echo `date`
