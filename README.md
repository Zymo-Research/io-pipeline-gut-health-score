<p align="center" width="100%">
   <img src="img/io-gut-health.gif" alt="Trust your gut - io-gut-health banner" style="width:100%;max-width:1000px;min-width:300px;display:block;margin:auto;" />
</p>

---

## 🧬 What is io-gut-health?

**io-gut-health** is a reproducible, modular Nextflow pipeline for gut microbiome profiling and scoring.  
It integrates microbiome tools (*MetaPhlAn, HUMAnN, GMWI2, Q2-predict-dysbiosis*) to deliver robust, scalable, and interpretable gut health metrics from metagenomic sequencing data.

---

## 📋 Prerequisites

- **Java 8+**
- **Nextflow** (v22.10.6 or later)
- **Docker** or **Singularity** (recommended for reproducibility)

---

## 🔧 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/lhsnam/io-gut-health.git
   cd io-gut-health
   ```
2. **Install Nextflow** (if not already):
   ```bash
   curl -s https://get.nextflow.io | bash
   mv nextflow ~/bin
   ```

---

## 🚀 Quick Start

1. **Prepare your sample sheet** (`design.csv`):

    ```csv
    sample,read_1,read_2,group,run_accession
    sample1,s1_run1_R1.fastq.gz,s1_run1_R2.fastq.gz,groupA,run1
    sample1,s1_run2_R1.fastq.gz,s1_run2_R2.fastq.gz,groupA,run2
    sample2,s2_run1_R1.fastq.gz,,groupB,,
    sample3,s3_run1_R1.fastq.gz,s3_run1_R2.fastq.gz,groupB,,
    ```

    💡 **Tip**: Use the [design-csv-creator](https://github.com/lhsnam/design-csv-creator) tool to automatically generate your `design.csv` file from a directory of FASTQ files.

2. **Launch the pipeline**:

   ```bash
   nextflow run main.nf \
     --design design.csv \
     --outdir results/io-gut-health \
     --tool gmwi \
     -profile local
   ```

   Replace `gmwi2` with `q2-predict` in `--tool` to use the alternative scoring method.

---

## 🔍 Inspecting Results

After the pipeline completes, your main results will be in the output directory you specified (e.g., `.results/`). Key outputs include:

- **GMWI2 scores:**  
  - File: `final/gmwi2_scores_table.tsv`  
  - Contains the Gut Microbiome Wellness Index 2 score for each sample.

- **Q2-predict dysbiosis scores:**  
  - File: `q2_predict_dysbiosis/dysbiosis_results.csv`  
  - Contains the Q2-predict dysbiosis score for each sample (if you used `--tool q2-predict`).

- **MetaPhlAn profiles:**  
  - File: `metaphlan/<sample>_metaphlan.txt`  
  - Contains the taxonomic profile (relative abundances) for each sample.

---

## 🏆 Features

- **End-to-end** gut microbiome scoring from raw reads
- **Parallelized, scalable, and reproducible** with Nextflow
- **Customizable** for local, cluster, or cloud environments
- **Clear outputs** for downstream analysis and visualization

---

## 📖 References

- [Nextflow](https://www.nextflow.io/docs/latest)
- [MetaPhlAn](https://github.com/biobakery/MetaPhlAn)
- [HUMAnN](https://github.com/biobakery/humann)
- [QIIME2](https://qiime2.org/)
- [GMWI2](https://github.com/danielchang2002/GMWI2)
- [q2-predict-dysbiosis](https://github.com/Kizielins/q2-predict-dysbiosis)
- [**io-gut-health**](https://github.com/lhsnam/io-gut-health)

---

## 👤 Author

**NamLHS**  
[GitHub](https://github.com/lhsnam) | [Google Scholar](https://scholar.google.com/citations?user=j6MKfFMAAAAJ&hl=en)

---

<p align="center"><i>Trust your gut.