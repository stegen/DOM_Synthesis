#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=step1-tforms
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=klongnecker@whoi.edu
#SBATCH --ntasks=1
#SBATCH --mem=4gb
#SBATCH --time=:30:00
#SBATCH --output=/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/logfiles_dir/step1-tforms.out
#SBATCH --error=/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/logfiles_dir/step1-tforms.error
#SBATCH --array=1-68%40 

#/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/output_dir
dir="$HOME/DOM_Synthesis/transformations_HPC"
cd "$dir"

in_dir="/vortexfs1/omics/kujawinski/data/DOMsynthesis"
out_dir="$dir/output_dir/$SLURM_JOB_NAME"
log_dir="$dir/logfiles_dir/$SLURM_JOB_NAME" #need a folder to hold the output results text files - there are zillions of them. 

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
conda activate untargKL4

Rscript --no-save --no-restore --verbose $dir/scripts_dir/tforms1.R "$in_dir" "$SLURM_ARRAY_TASK_ID" "$out_dir" > "$log_dir/${SLURM_JOB_NAME}_${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}.Rout" 2>&1 > "$log_dir/${SLURM_JOB_NAME}_$ionMode_${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}.log"

echo `date`
