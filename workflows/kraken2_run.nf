
// ----------------Workflow---------------- //

include { TrimFastQ } from '../modules/trimming/trimgalore.nf'
include { Kraken } from '../modules/kraken/kraken.nf'

workflow KRAKEN2 {

  // CREATING KRAKEN2 DB CHANNEL ---------- //

  Channel.fromPath("${params.kraken_database_path}/*{kmer_distrib,k2d,txt,map}")
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

  // KRAKEN ------------------------------- //

  // Running Kraken2
  Kraken(kraken_database, TrimFastQ.out.trimmed_fastq_files)

}