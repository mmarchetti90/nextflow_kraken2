process Kraken {

  // Filter reads taxonomically with Kraken
  
  label 'kraken2'

  publishDir "${projectDir}/k2_reports", mode: "copy", pattern: "*.report"
  publishDir "${projectDir}/k2_outputs", mode: "copy", pattern: "*.out"

  input:
  path(kraken_db)
  tuple val(sample_id), path(read1), path(read2)

  output:
  path "*.report", emit: kraken_reports
  path "*.out", emit: kraken_outputs

  """
  # run kraken to taxonomically classify reads
  if [[ "${read2}" == "mock.trim.fastq" ]]
  then

    kraken2 \
    --db . \
    --gzip-compressed \
    --threads \$SLURM_CPUS_ON_NODE \
    --report ${sample_id}_kraken.report \
    --report-minimizer-data \
    --use-names \
    --output ${sample_id}.out \
    ${read1}

  elif [[ "${read2}" == "mock.clean.fastq" ]]
  then

    kraken2 \
    --db . \
    --gzip-compressed \
    --threads \$SLURM_CPUS_ON_NODE \
    --report ${sample_id}_kraken.report \
    --report-minimizer-data \
    --use-names \
    --output ${sample_id}.out \
    ${read1}

  else

    kraken2 \
    --db . \
    --paired \
    --gzip-compressed \
    --threads \$SLURM_CPUS_ON_NODE \
    --report ${sample_id}_kraken.report \
    --report-minimizer-data \
    --use-names \
    --output ${sample_id}.out \
    ${read1} ${read2}

  fi
  """

}
