from snakemake.shell import shell

# input,output
query = snakemake.input.query
out = snakemake.output[0]

# parameters
db_prefix = snakemake.params.db_prefix
outfmt = snakemake.params.get("outfmt", "")
threads = snakemake.params.threads
evalue = snakemake.params.evalue

# command line
shell(f"""
    blastn -query {query} -db {db_prefix} -out {out} \
    -outfmt '{outfmt}' \
    -num_threads {threads} \
    -evalue {evalue} \
""")
