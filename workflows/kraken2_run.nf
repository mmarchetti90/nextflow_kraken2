
// ----------------Workflow---------------- //

include { TrimFastQ } from '../modules/trimming/trimgalore.nf'
include { BwaIndex } from '../modules/mapping/bwa_indexing.nf'
include { RemoveContaminants } from '../modules/mapping/remove_contaminants.nf'
include { Kraken } from '../modules/kraken/kraken.nf'
include { Bracken as BrackenG } from '../modules/kraken/bracken.nf'
include { Bracken as BrackenS } from '../modules/kraken/bracken.nf'

workflow KRAKEN2 {

  // CREATING KRAKEN2 DB CHANNEL ---------- //

  Channel.fromPath("${params.kraken_database_path}")
    .collect()
    .set{ kraken_database }

  // CREATING RAW-READS CHANNEL ----------- //

  Channel
    .fromPath("${params.reads_manifest_path}")
    .splitCsv(header: true, sep: '\t')
    .map{row -> tuple(row.sample, file(row.fastq1), file(row.fastq2))}
    .set{ raw_reads }

  // TRIMGALORE --------------------------- //

  TrimFastQ(raw_reads)

  // REMOVE CONTAMINANTS ------------------ //

  if (params.remove_contaminants) {

    // Channel for fasta reference of contaminant genome
    Channel.fromPath("${params.contaminant_fasta}")
      .set{ contaminant_fasta }

    // Creating channel for existing BWA index, or building de novo
    if (new File("${params.bwa_index_dir}/${params.bwa_index_prefix}.amb").exists()) {

      Channel.fromPath("${params.bwa_index_dir}/*{amb,ann,bwt,pac,sa}")
        .collect()
        .set{ bwa_index }

    }
    else {

      BwaIndex(contaminant_fasta)

      bwa_index = BwaIndex.out.bwa_index.collect()

    }

    // Aligning to contaminant
    RemoveContaminants(contaminant_fasta, bwa_index, TrimFastQ.out.trimmed_fastq_files)

    kraken_input_reads = RemoveContaminants.out.clean_reads

  }
  else {

    kraken_input_reads = TrimFastQ.out.trimmed_fastq_files

  }

  // KRAKEN ------------------------------- //

  // Running Kraken2
  Kraken(kraken_database, kraken_input_reads)

  // BRACKEN ------------------------------ //

  // Running Bracken to quantify at genus level
  BrackenG('G', kraken_database, Kraken.out.kraken_reports)

  // Running Bracken to quantify at species level
  BrackenS('S', kraken_database, Kraken.out.kraken_reports)

}