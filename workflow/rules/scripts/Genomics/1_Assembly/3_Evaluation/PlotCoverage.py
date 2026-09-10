from snakemake.shell import shell

nano = snakemake.input.nano

out = snakemake.output.out
outraw = snakemake.output.outraw
threads = snakemake.params.threads

shell(f"""plotCoverage -b {nano} \
-o {out} -p {threads} --verbose --outRawCounts {outraw}""")
