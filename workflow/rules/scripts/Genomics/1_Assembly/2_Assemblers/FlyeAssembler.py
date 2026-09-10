from snakemake.shell import shell

input = snakemake.input
out_dir = snakemake.output.out_dir
genome_size = snakemake.params.genome_size
threads = snakemake.params.threads

shell(f"""flye --nano-hq {input} --genome-size {genome_size} --threads {threads} --out-dir {out_dir}""")
