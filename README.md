coralAssembly Package 
=============

This package is for Transcriptome isoform clustering and annotation

Included files: 

  Script_1.pl :
   Given a dir of fasta files and a  blast db, do and parse the blast.
   Note 1: The db should be formated first. 
   Note 2: The config file should be provided for the --config option.
   
  Script_2.pl
   Takes the outout file from the Script_1.pl and perform the pre-clustering step for TRIBE-MCL
   
  Script_3.pl
   Run and parse bowtie

  Script_S1.pl
  Combines the NGS Illumina PE reads 

  Script_S2.pl
  Generate the statistics of the assembled Fasta file 

  Script_S3.sh
  Fliters fasta sequences shorter than centain (It has to be specified in the script) length

  Script_S4.pl
  Generates small fasta files from a biger fasta file.  The Id list should be provided in a new text file. 
  Note: The $seqin should be changd in the script
  

  Script_S5.pl
  Takes the amino acid predition fasta file from getorf. It extracts the corresponding regions in the original cDNA Nucleotide 
  file. 

  config_BlastP-e5: Config file to run blastP
  
  bowtie_config: Config file to run perl implemented bowtie to calculate FPKM
  
  External Dependencies:
   Perl  
   BioPerl
	 Blast 
   
	
