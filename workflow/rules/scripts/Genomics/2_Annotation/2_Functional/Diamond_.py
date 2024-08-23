from snakemake.shell import shell

genome= snakemake.input.genome
db = snakemake.input.db

outfmt = snakemake.params.outfmt
threads = snakemake.params.threads
more_sensitive = snakemake.params.more_sensitive
evalue = snakemake.params.evalue

output = snakemake.output

shell(f"""diamond blastp --query {genome} \
--db {db} \
--out {output} \
--outfmt {outfmt} \
--threads {threads} \
--evalue {evalue} \
--more-sensitive {more_sensitive} \
""")
