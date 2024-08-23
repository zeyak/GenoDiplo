rule prodigal:
    input:
         assembly="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta",
    output:
          gff="results/Genomics/2_Annotation/1_Structural/prodigal/{assembler}/genome.gff",
          faa="results/Genomics/2_Annotation/1_Structural/prodigal/{assembler}/genome.faa",
          #ffn="results/Genomics/2_Annotation/1_Structural/prodigal/{assembler}/genome.ffn",
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/2_Annotation/1_Structural/ProdigalAnnotation.py"

rule glimmerhmm_:
    input:
        exon = "resources/TrainGlimmerHMM/training_for_glimmerhmm.cds",
        mfasta = "resources/TrainGlimmerHMM/ssk.cns.fa",
        #exon="resources/TrainGlimmerHMM/spiro_exons.cds",
        #mfasta= "resources/TrainGlimmerHMM/S_salmonicida.fa",
        #mfasta= "resources/TrainGlimmerHMM/S_salmonicidaCDS.fasta",
        genome= "results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta"
    params:
          n=150,
          v=50
    output:
        train_dir = directory("results/Genomics/2_Annotation/1_Structural/glimmerhmm/{assembler}/trainingglimmerhmm"),
        gff="results/Genomics/2_Annotation/1_Structural/glimmerhmm/{assembler}/genome.gff",
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/2_Annotation/1_Structural/GlimmerHMMAnnotation.py"
"""
rule glihmmerhmm_:
    input:
        genome_file= "results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta",
        exon_file= "resources/TrainGlimmerHMM/training_for_glimmerhmm.cds",
        mfasta_file= "resources/TrainGlimmerHMM/ssk.cns.fa"
    output:
        gff_output= "results/Genomics/2_Annotation/1_Structural/glimmerhmm/{assembler}/genome.gff",
        conf_file= "results/Genomics/2_Annotation/1_Structural/glimmerhmm/trainingglimmerhmm/{assembler}/train_0_100.cfg"
    params:
        home_dir= "results/Genomics/2_Annotation/1_Structural/glimmerhmm/",
        #train_dir="results/Genomics/2_Annotation/1_Structural/glimmerhmm/trainingglimmerhmm2",
        #train_dir= "/opt/zeynep/barkhanus/.snakemake/conda/6b972f4ed338544efcb65943eb789bcf/bin/trainingglimmerhmm2/{assembler}/"
    conda:
         "envs/genomics.yaml"
    script:
     "scripts/Genomics/2_Annotation/1_Structural/glimmerhmm.py"

"""
rule augustus:
    input:
        genome = "resources/{type}/hybrid_masurca_masked.fasta"
    output:
        directory("output/{type}/Augustus"),
        "output/{type}/Augustus/HIN.gff"
    params:
        num_threads = 30,
        species= "BUSCO_sp_tetrahymena_long"
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/augustus.py"

rule V3_busco_geneset:
    input:
        geneset = "resources/{type}/geneset/HIN.faa"
    output:
        directory("output/{type}/V3/HIN_geneset_V3_eukaryota/")
    params:
        lineage = "resources/3_BUSCO/V3/eukaryota_odb9",
        mode = "prot",
        num_threads = 30,
        out_name = "HIN_v3_euk"
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/busco_v3.py"

rule busco_transcriptome:
    input:
        trans = "resources/{type}/{assesment}/HIN_trans.fasta"
    output:
        directory("output/{type}/{assesment}/HIN_trans")
    params:
        lineage = "eukaryota_odb10",
        mode = "tran",
        tran = True,
        num_threads = 30,
        species= "tetrahymena"
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/busco.py"

rule busco_plot:
    input:
        "resources/{type}/summaries/"
    output:
        directory("resources/{type}/summaries/")
    conda:
        "envs/genomics.yaml"
    shell:
        "generate_plot.py -wd {input}"

#Functional Annotation
rule make_diamond_db:
    input:
        "resources/DiploProteoms/{db}.fa"
    output:
        "resources/DiploProteoms/{db}.db.dmnd"
    conda:
        "envs/genomics.yaml"
    shell:
        "diamond makedb --in {input} --db {output}"

"""rule diamond_blastp:
    input:
        genome="results/Genomics/2_Annotation/1_Structural/{annotation}/{assembler}/genome.faa",
        db= "resources/DiploProteoms/{db}.db.dmnd"
    output:
        "results/Genomics/2_Annotation/2_Functional/blastp/{annotation}/{assembler}/{db}/genome.blastp"
    params:
        outfmt="6 qseqid sseqid evalue qlen slen length pident stitle",
        evalue=0.00001,
        threads=32,
        max_target_seqs=1,
        max_hsps=1,
        more_sensitive="-b5 -c1"
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/2_Annotation/2_Functional/Diamond.py"
        """

rule diamond_blastp_:
    input:
        genome = "results/Genomics/2_Annotation/1_Structural/{annotation}/{assembler}/genome.faa",
        db = "resources/DiploProteoms/{db}.db.dmnd"
    output:
          "results/Genomics/2_Annotation/2_Functional/blastp/{annotation}/{assembler}/{db}/genome.blastp"
    params:
          outfmt="6 qseqid sseqid evalue qlen slen length pident stitle",
          evalue=0.00001,
          threads=32,
          more_sensitive="-b5 -c1"
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/2_Annotation/2_Functional/Diamond_.py"

rule eggnogmapper:
    input:
         proteome="results/Genomics/2_Annotation/1_Structural/{annotation}/{assembler}/genome.faa"
    output:
          "results/Genomics/2_Annotation/2_Functional/eggnogmapper/{annotation}/{assembler}/eggnogmapper_results.tsv"
    params:
          threads=32,
          diamond="diamond",
          outdir="results/Genomics/2_Annotation/2_Functional/eggnogmapper/{annotation}/{assembler}/",
          datadir="/data/zeynep/eggnog-mapper/data/",

    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/2_Annotation/2_Functional/Eggnogmapper.py"
rule interproscan:
    input:
         proteome="results/Genomics/2_Annotation/1_Structural/{annotation}/{assembler}/genome.faa"
    output:
          out= "results/Genomics/2_Annotation/2_Functional/interproscan/{annotation}/{assembler}/interproscan_results.tsv"
    params:
          threads=32,
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/2_Annotation/2_Functional/Interproscan.py"
