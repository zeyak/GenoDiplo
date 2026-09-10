# Running the GenoDiplo pipeline on the *S. barkhanus* Nanopore reads

A practical, step-by-step guide. Commands are written for macOS / Linux (bash or zsh). Where macOS and Linux differ, both are shown.

> **Important macOS note.** Many bioconda tools used by this pipeline (Flye, MaSuRCA, RepeatMasker, RepeatModeler, InterProScan, eggNOG-mapper) ship Linux-only or `osx-64`-only builds. On Apple Silicon you must either:
> 1. Force conda to use `osx-64` (Rosetta) packages, **or**
> 2. Run the pipeline on a Linux machine / cluster / Docker container.
>
> The cleanest path on Apple Silicon is option 1, shown in Step 1.

---

## Step 1. Install conda (Miniforge recommended)

Miniforge is a minimal conda installer that defaults to the conda-forge channel and works well with bioconda. It is preferred over Anaconda for bioinformatics.

### macOS (Apple Silicon, M1/M2/M3/M4)
```bash
# Download the osx-64 (Intel) build so bioconda packages resolve via Rosetta
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh
bash Miniforge3-MacOSX-x86_64.sh -b -p "$HOME/miniforge3"

# Initialise your shell
"$HOME/miniforge3/bin/conda" init "$(basename "${SHELL}")"

# Force this conda installation to always use osx-64
"$HOME/miniforge3/bin/conda" config --set subdir osx-64
```
Then **close and reopen your terminal** so conda activates correctly.

### macOS (Intel) or Linux
```bash
# macOS Intel
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh
bash Miniforge3-MacOSX-x86_64.sh -b -p "$HOME/miniforge3"

# Linux x86_64
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh -b -p "$HOME/miniforge3"

"$HOME/miniforge3/bin/conda" init "$(basename "${SHELL}")"
```

### Verify
```bash
conda --version
mamba --version    # mamba ships with Miniforge
```

---

## Step 2. Clone the GenoDiplo repository

You already have the repo at `~/Documents/Claude/Projects/GenoDiplo`, so this step is informational. If you ever need to clone it fresh:

```bash
git clone https://github.com/zeyak/GenoDiplo.git
cd GenoDiplo
```

For this tutorial, just `cd` into the existing folder:
```bash
cd ~/Documents/Claude/Projects/GenoDiplo
```

---

## Step 3. The environment yaml file

The repo ships two yaml files. You don't need to create one from scratch.

### `environment.yml` (top-level, controls Snakemake itself)
```yaml
name: GenoDiplo
channels:
  - bioconda
  - conda-forge
  - defaults
dependencies:
  - conda-forge::mamba
  - conda-forge::python>=3.8
  - bioconda::snakemake>=7.0
```

### `workflow/rules/envs/genomics.yaml` (controls per-rule tools)
This is auto-installed by Snakemake when you pass `--use-conda`. You do not install it manually. It contains Flye, FastQC, QUAST, Prodigal, DIAMOND, GlimmerHMM, RepeatMasker, tRNAscan-SE, Barrnap, CD-HIT, and so on.

If you want to pin versions for reproducibility, edit `environment.yml` like this:
```yaml
name: GenoDiplo
channels:
  - bioconda
  - conda-forge
  - defaults
dependencies:
  - conda-forge::mamba
  - conda-forge::python=3.11
  - bioconda::snakemake=7.32.4
  - bioconda::snakemake-wrapper-utils
```

---

## Step 4. Install Snakemake (create the GenoDiplo environment)

From the repo root:
```bash
cd ~/Documents/Claude/Projects/GenoDiplo
conda env create -f environment.yml
conda activate GenoDiplo
```

Verify:
```bash
snakemake --version
```

If `conda env create` is slow, use mamba (faster solver):
```bash
mamba env create -f environment.yml
conda activate GenoDiplo
```

---

## Step 5. Place the *S. barkhanus* FASTQ file in the expected location

The pipeline reads its input path from `workflow/config/config.yaml`. The relevant key is `data_dir`, and the Snakefile rule `flye` expects:

```
{data_dir}/DNA/{process}/nanopore.fastq.gz
```

where `{process}` is `raw` for the unprocessed reads (see `rule all` in `workflow/Snakefile`).

### 5a. Pick a data directory
Decide where your sequencing data lives. For example:
```bash
mkdir -p ~/genodiplo_data/DNA/raw
```

### 5b. Copy and rename your barkhanus FASTQ
The pipeline expects the file to be named exactly `nanopore.fastq.gz`. If your file is called e.g. `barkhanus_nanopore.fastq.gz`:
```bash
cp /path/to/your/barkhanus_nanopore.fastq.gz ~/genodiplo_data/DNA/raw/nanopore.fastq.gz
```

If the file is uncompressed (`.fastq`), compress it first:
```bash
gzip -c /path/to/barkhanus.fastq > ~/genodiplo_data/DNA/raw/nanopore.fastq.gz
```

### 5c. Edit `workflow/config/config.yaml`
Open it in any editor and update these lines:
```yaml
data_dir: /Users/<you>/genodiplo_data
est_file: /Users/<you>/genodiplo_data/EST/S_barkhanus_cloneMiner_cDNA_library.fasta
genome_size: 114m
threads: 8        # set this to the number of cores you actually have
```

If you do not have the EST/cDNA library file yet, the `blastn_est` evaluation step will fail. To do a first dry-run-only test, you can comment out that line in `rule all` inside `workflow/Snakefile`.

---

## Step 6. Run the pipeline

Always run snakemake from the `workflow/` directory (because the Snakefile uses relative paths like `config/config.yaml` and `rules/...`).

### 6a. Dry-run first (this never executes anything, it just plans the DAG)
```bash
cd ~/Documents/Claude/Projects/GenoDiplo/workflow
snakemake --use-conda --cores 8 -n
```
The `-n` flag means "dry run". If you see a green summary of jobs, you are ready to go.

### 6b. Visualise the DAG (optional)
```bash
snakemake --use-conda --cores 1 --dag | dot -Tpng > dag.png
```
(requires `graphviz`: `conda install -c conda-forge graphviz`)

### 6c. Real run
```bash
snakemake --use-conda --cores 8
```
First run is slow because Snakemake creates the per-rule conda env from `workflow/rules/envs/genomics.yaml`. Expect 10 to 30 minutes just for that the first time.

To resume after a failure:
```bash
snakemake --use-conda --cores 8 --rerun-incomplete
```

To force everything to re-run:
```bash
snakemake --use-conda --cores 8 --forceall
```

---

## Step 7. Where do results land?

All outputs go under `workflow/results/`:
- `results/Genomics/1_Assembly/1_Preprocessing/fastqc_before_trimming/` — FastQC HTML reports
- `results/Genomics/1_Assembly/2_Assemblers/flye/raw/` — Flye assembly (`assembly.fasta`)
- `results/Genomics/1_Assembly/3_Evaluation/quast/flye/raw/` — QUAST contiguity stats
- `results/Genomics/1_Assembly/3_Evaluation/multiqc/flye/raw/` — combined MultiQC report
- `results/Genomics/2_Annotation/1_Structural/prodigal/flye/raw/genome.gff` — Prodigal gene calls
- `results/Genomics/2_Annotation/2_Functional/blastp/...` — DIAMOND BLASTp hits
- `results/ComparativeGenomics/...` — RepeatMasker, tRNAscan, Barrnap, CD-HIT, OrthoFinder outputs

---

## Quick reference (the whole flow in 10 commands)

```bash
# 1. Install Miniforge (macOS Apple Silicon shown)
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh
bash Miniforge3-MacOSX-x86_64.sh -b -p "$HOME/miniforge3"
"$HOME/miniforge3/bin/conda" init zsh
"$HOME/miniforge3/bin/conda" config --set subdir osx-64
# (reopen terminal)

# 2. Go to the cloned repo
cd ~/Documents/Claude/Projects/GenoDiplo

# 3. Create the Snakemake env
conda env create -f environment.yml
conda activate GenoDiplo

# 4. Prepare data
mkdir -p ~/genodiplo_data/DNA/raw
cp /path/to/barkhanus.fastq.gz ~/genodiplo_data/DNA/raw/nanopore.fastq.gz

# 5. Edit workflow/config/config.yaml so data_dir points to ~/genodiplo_data

# 6. Run
cd workflow
snakemake --use-conda --cores 8 -n   # dry-run
snakemake --use-conda --cores 8      # real run
```

---

## Troubleshooting

**`PackagesNotFoundError: flye / repeatmasker / interproscan` on macOS.**
You are on Apple Silicon without the `osx-64` subdir override. Re-run:
```bash
conda config --set subdir osx-64
```
and recreate the env.

**`MissingInputException: Missing input files for rule flye: ...nanopore.fastq.gz`.**
Your file is not at `{data_dir}/DNA/raw/nanopore.fastq.gz`. Check the path and the exact filename.

**`Error: directory cannot be locked`.**
A previous snakemake run did not clean up. Unlock it:
```bash
snakemake --unlock
```

**Pipeline is slow / runs out of RAM.**
Lower `--cores` and lower `threads` in `config.yaml`. Flye on a 114 Mb genome typically needs ~16 GB RAM.

**EST / NR / eggNOG databases.**
These are external downloads (tens of GB). Set their paths in `config.yaml` before running the corresponding rules, or comment those targets out of `rule all` in the Snakefile.
