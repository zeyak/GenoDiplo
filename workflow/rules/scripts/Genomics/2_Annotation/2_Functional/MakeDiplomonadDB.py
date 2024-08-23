from snakemake.shell import shell

muris= snakemake.input.muris
wb= snakemake.input.wb
spiro = snakemake.input.spiro
trepo = snakemake.input.trepo #trasncriptome proteome

diplomonad_proteomes = snakemake.output.diplomonad_proteomes
diplomonad_db = snakemake.output.diplomonad_db


shell(f"cat {muris} {wb} {spiro} {trepo}> {diplomonad_proteomes.faa}")
shell(f"diamond makedb --in {diplomonad_proteomes.faa} --db {diplomonad_db}")


