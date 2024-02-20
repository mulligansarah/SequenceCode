### Importing raw fastq files into qiime2 ###

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path /work/sbauman/project/fastq/manifest.tsv \ 
  --output-path /work/sbauman/project/fastq/paired-end-demux.qza \  
  --input-format PairedEndFastqManifestPhred33V2
  

#Summary of the imported raw reads 
qiime demux summarize \
  --i-data paired-end-demux.qza \
  --o-visualization paired-end-demux.qzv
  


###To activate multithreading###
When available, pass --p-n-threads with either 0, to use all available cores, or some value larger than 1 to specify the number of cores to use

#EXAMPLE
--p-n-threads 8 will use 8 cores for the analysis
  
### Sequence quality control and feature table construction using dada2 ###


April 2018 Update
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs paired-end-demux.qza \
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-f 270 \
  --p-trunc-len-r 180 \
  --p-n-threads 8 \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza

#FeatureTable and FeatureData Summaries 
qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file sample-metadata.tsv

qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv

#Visualize the Denoising Statistics
qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization denoising-stats.qzv



### Taxonomic Assignments ###

*** qiime2-amplicon-2023.9 ***

qiime feature-classifier classify-sklearn \
  --i-classifier /sbauman/work/project/fastq/qiime2-amplicon-2023.9/silva138-99-341-806-nb-classifier.qza \
  --i-reads rep-seqs.qza \
  --p-n-jobs -2 \
  --p-reads-per-batch "User Defined" \
  --o-classification silva-138-99-V3V4-taxonomy.qza

qiime metadata tabulate \
  --m-input-file silva-138-99-V3V4-taxonomy.qza \
  --o-visualization silva-138-99-V3V4-taxonomy.qzv
    
qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy silva-138-99-V3V4-taxonomy.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization silva-138-99-V3V4-taxa-bar-plots.qzv
