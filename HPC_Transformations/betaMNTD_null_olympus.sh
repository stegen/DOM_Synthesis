for i in $(seq 1 3)
       do
          sbatch betaMNTD_null_batch_olympus_unix.txt $i

done
