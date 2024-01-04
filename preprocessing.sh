# !/bin/bash
#SBATCH --account=compute_canada_account
#SBATCH --time=12:00:00
#SBATCH --mem-per-cpu=16G
#SBATCH --cpus-per-task=8
#SBATCH --output=preprocessing.log

# Load the necessary modules
module load StdEnv/2020
module load gcc/9.3.0
module load sra-toolkit/3.0.0
module load cellranger/6.1.2

# Navigate to the directory where you want to work
cd /home/renad/scripts/De_Micheli_2020/preprocessing   

# Define SRR accession numbers (Source: De Micheli et al.) 
accession_numbers=("SRR10870296" "SRR10870297" "SRR10870298" "SRR10870299" "SRR10870300" "SRR10870301" "SRR10870302" "SRR10870303" "SRR10870304" "SRR10870305")

# Loop through accession numbers for prefetch and fastq-dump
for accession in "${accession_numbers[@]}"; do
    echo "Downloading and converting $accession"

    prefetch $accession

    fastq-dump --split-files $accession   # You can add more options if needed
done

# Perform Cell Ranger preprocessing 
cellranger count --id=my_sample --transcriptome=/path/to/transcriptome my_fastq_directory

#!/bin/bash
# This script performs Cell Ranger preprocessing and UMI matrix generation

# Define variables
CELLRANGER_DIR="/~/cellranger"  
FASTQ_DIR="/~/De_Micheli_2020/fastq_files"      
OUTPUT_DIR="/~/De_Micheli_2020/output_directory" 
SAMPLE_NAME="sample_name"             

# Load Cell Ranger module
module load cellranger

# Change to the Cell Ranger directory
cd $CELLRANGER_DIR

# Run Cell Ranger count
cellranger count \
  --id=$SAMPLE_NAME \
  --transcriptome=/~/refdata-gex-mm10-2020-A \ #mm10 reference transcriptome
  --fastqs=$FASTQ_DIR \
  --sample=$SAMPLE_NAME \
  --localmem=64  

# Change to the output directory
cd $OUTPUT_DIR/$SAMPLE_NAME

# Run Cell Ranger aggr (for multiple samples)
# cellranger aggr \
#   --id=aggregated_samples \
#   --csv=samplesheet.csv \
#   --normalize=mapped

# Run Cell Ranger reanalyze (if needed)
# cellranger reanalyze \
#   --id=reanalyzed_samples \
#   --matrix=filtered_gene_bc_matrices

# Run Cell Ranger mat2csv to generate UMI count matrix
cellranger mat2csv .  # Use the current directory as input

# Your UMI count matrix is now available in the output directory
# You can further analyze or visualize the data using other tools or scripts



# Add any additional steps or commands you need for preprocessing and UMI matrix generation

echo "Preprocessing and UMI matrix generation completed"
