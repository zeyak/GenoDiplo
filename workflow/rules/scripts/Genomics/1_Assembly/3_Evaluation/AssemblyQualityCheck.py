from snakemake.shell import shell

assembly = snakemake.input.assembly
threads = snakemake.params.threads
report_dir = snakemake.output.report_dir

shell(f"quast.py {assembly} -o {report_dir} --threads {threads} --eukaryote")
