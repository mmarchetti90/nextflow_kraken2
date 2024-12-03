process TrimFastQ {

  // Trim reads for quality

  label 'trimgalore'

  //publishDir "${projectDir}/trimmed_fastq", mode: "copy", pattern: "*.fq.gz"
  publishDir "${projectDir}/fastqc_reports", mode: "copy", pattern: "*_fastqc.{html,zip}"
  publishDir "${projectDir}/trimming_reports", mode: "copy", pattern: "*_trimming_report.txt"

  input:
  tuple val(sample_id), path(read1), path(read2)

  output:
  path "*_fastqc.{html,zip}", emit: fastqc_reports
  path "*_trimming_report.txt", emit: trimming_reports
  tuple val(sample_id), path("{${sample_id}_val_1.fq.gz,${sample_id}_trimmed.fq.gz}"), path("{${sample_id}_val_2.fq.gz,mock.trim.fastq}"), emit: trimmed_fastq_files

  """
  # Trim adapters and short reads, for all platforms but NextSeq
  if [[ "${read2}" == "mock.fastq" ]]
  then

    trim_galore \
      --cores \$SLURM_CPUS_ON_NODE \
      --output_dir . \
      --basename ${sample_id} \
      --fastqc \
      --gzip \
      ${read1}

    # Adding mock read2 output
    touch mock.trim.fastq

  else

    trim_galore \
    --cores \$SLURM_CPUS_ON_NODE \
    --output_dir . \
    --basename ${sample_id} \
    --fastqc \
    --gzip \
    --paired \
    ${read1} ${read2}

  fi
  """

}