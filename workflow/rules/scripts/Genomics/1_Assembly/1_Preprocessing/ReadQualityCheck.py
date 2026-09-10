from snakemake.shell import shell
import os

input_dir = snakemake.input.input_dir
threads = snakemake.params.threads
out_dir = snakemake.output.out_dir

if not os.path.exists(out_dir):
    os.makedirs(out_dir)
    print(f"Directory created: {out_dir}")
else:
    print(f"Directory already exists: {out_dir}")
    shell(f"fastqc --threads {threads} {input_dir}/* -o {out_dir}")
