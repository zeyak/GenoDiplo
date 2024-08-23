from snakemake.shell import shell

assembly = snakemake.input.assembly

gff = snakemake.output.gff
faa = snakemake.output.faa
 
shell(f"prodigal -i {assembly} -o {gff} -g 6 -f gff -c -a {faa}""")
