rule fastqc_before_trimming:
    input:
         input_dir="/data/zeynep/barkhanus_data/DNA/raw",
    params:
          threads=32,
    output:
          out_dir=directory("results/Genomics/1_Assembly/1_Preprocessing/fastqc_before_trimming/"),
    conda:
         "envs/genomics.yaml",
    script:
          "scripts/Genomics/1_Assembly/1_Preprocessing/ReadQualityCheck.py"

#Assembly
rule flye:
    input:
         reads="/data/zeynep/barkhanus_data/DNA/{process}/nanopore.fastq.gz",
    params:
          genome_size="114m",
          threads=32,
    output:
          #out_dir=directory("results/Genomics/1_Assembly/2_Assemblers/flye/{process}/")
           out_dir= "results/Genomics/1_Assembly/2_Assemblers/flye/{process}/assembly.fasta"
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/2_Assemblers/FlyeAssembler.py"

rule setup_nr_db:  #FIX how to actuvste this before running blastn
    output:
        outdir = protected(directory("/data/zeynep/databases"))
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/3_Evaluation/setup_nr_db.py"

rule blastn:
    input:
        query="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta",
        db="/data/zeynep/databases"
    output:
        "results/Genomics/1_Assembly/3_Evaluation/blastn/{assembler}/{db}/assembly.blastn"
    params:
        outfmt= "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen stitle",
        threads=32,
        evalue=1e-10,
        db_prefix="/data/zeynep/databases/{db}"
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/3_Evaluation/blastn.py"

rule makeblastdb:
    input:
        "results/Genomics/1_Assembly/2_Assemblers/{assembler}/{db}.fasta"
    output:
        multiext("results/Genomics/1_Assembly/2_Assemblers/{assembler}/]{db}",
            ".ndb",
            ".nhr",
            ".nin",
            ".not",
            ".nsq",
            ".ntf",
            ".nto")
    params:
          outname="results/Genomics/1_Assembly/2_Assemblers/{assembler}/{db}"
    conda:
        "envs/genomics.yaml"
    shell:
        "makeblastdb -in {input} -dbtype nucl -out {params.outname}"

rule blastn_EST:
    input:
        #query="resources/RawData/S_barkhanus_cloneMiner_cDNA_library.fasta",
        query="/data/zeynep/barkhanus_data/EST/S_barkhanus_cloneMiner_cDNA_library.fasta",
        db="results/Genomics/1_Assembly/2_Assemblers/{assembler}/{db}.ndb"
    output:
        "results/Genomics/1_Assembly/3_Evaluation/blastn/{assembler}/{db}_est.blastn"
    params:
        outfmt= "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen stitle",
        threads=32,
        evalue=1e-10,
        db_prefix="results/Genomics/1_Assembly/2_Assemblers/{assembler}/{db}"
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/3_Evaluation/blastn.py"

"""rule make_diamond_db_assembly:
    input:
        "results/Genomics/1_Assembly/2_Assemblers/{assembler}/{db}.fasta"
    output:
        "results/Genomics/1_Assembly/2_Assemblers/{assembler}/{db}.db.dmnd"
    conda:
        "envs/genomics.yaml"
    shell:
        "diamond makedb --in {input} --db {output}"

rule diamond_blastn_est_tag:
    input:
        #query="resources/RawData/S_barkhanus_cloneMiner_cDNA_library.fasta",
        query= "/data/zeynep/barkhanus_data/EST/S_barkhanus_cloneMiner_cDNA_library.fasta",
        db="results/Genomics/1_Assembly/2_Assemblers/{assembler}/{db}.db.dmnd"

    output:
        "results/Genomics/1_Assembly/3_Evaluation/blastn/{assembler}/{db}_est.blastn"
    params:
        outfmt= "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen stitle",
        threads=32,
        evalue=1e-10,
        db_prefix="results/Genomics/1_Assembly/2_Assemblers/{assembler}/"
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/3_Evaluation/Diamond_est.py"""

rule meryl:
    input:
         genome="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta",
    output:
          merylDB=directory("results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/merlyDB"),
          repetitive_k15="results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/repetitive_k15.txt",
    params:
          threads=30,
          nanopore=True
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/CalculateKmerLongReads.py"

rule winnowmap:
    input:
         genome="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta",
         long_read="/data/zeynep/barkhanus_data/DNA/raw/{long_read}.fastq.gz",
         merylDB="results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/merlyDB",
         repetitive_k15="results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/repetitive_k15.txt",
    output:
          sorted_bam="results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/{long_read}.bam",
    params:
          threads=32,
          nanopore=True
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/MapLongReadsToAssembly.py"

#Evaluation
rule quast:
    input:
         assembly="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta",
    params:
          threads=32
    output:
          report_dir=directory("results/Genomics/1_Assembly/3_Evaluation/quast/{assembler}/")
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/AssemblyQualityCheck.py"

rule multiqc:
    input:
         input_dir="results/Genomics/1_Assembly/",
    params:
          threads=32
    output:
          out_dir=directory("results/Genomics/1_Assembly/3_Evaluation/multiqc/{assembler}")
    conda:
         "envs/genomics.yaml"
    shell:
         'multiqc {input.input_dir} -o {output.out_dir}'

rule plot_coverage_cont:
    input:
         #coverage on assembley
         nano="results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/nanopore.bam"
    output:
          out="results/Genomics/1_Assembly/3_Evaluation/deeptools/{assembler}.png",
          outraw="results/Genomics/1_Assembly/3_Evaluation/deeptools/{assembler}/outRawCounts.txt"
    params:
          threads=32,
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/PlotCoverage.py"

