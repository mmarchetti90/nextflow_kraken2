process RemoveContaminants {

  // Map reads to a contaminant species (e.g. human)
  
  label 'mapping'

  publishDir "${projectDir}/cleaned_reads", mode: "copy", pattern: "*.fastq"
  publishDir "${projectDir}/cleaning_stats", mode: "copy", pattern: "*_mapping.log"

  input:
  each path(reference_fasta)
  path(bwa_index)
  tuple val(sample_id), path(read1), path(read2)

  output:
  tuple val(sample_id), path("${sample_id}_cleaned_R1.fq.gz"), path("{${sample_id}_cleaned_R2.fq.gz,mock.clean.fastq}"), emit: clean_reads
  path "${sample_id}_mapping.log", emit: mapping_reports

  """
  # Mapping with BWA
  if [[ "${read2}" == "mock.trim.fastq" ]]
  then

    # Mapping with BWA
    bwa mem \
    -t \$SLURM_CPUS_ON_NODE \
    ${reference_fasta} \
    ${read1} > mapped.sam

  else

    # Mapping with BWA
    bwa mem \
    -t \$SLURM_CPUS_ON_NODE \
    ${reference_fasta} \
    ${read1} ${read2} > mapped.sam

  fi

  # Sort and convert to bam
  samtools sort \
  -@ \$SLURM_CPUS_ON_NODE \
  -o mapped_coord_sorted.sam \
  mapped.sam

  # Extracting mapping stats
  samtools flagstat \
  -@ \$SLURM_CPUS_ON_NODE \
  mapped_coord_sorted.sam > ${sample_id}_mapping.log

  # Extract unmapped reads
  samtools view \
  -@ \$SLURM_CPUS_ON_NODE \
  -h \
  -f 4 \
  mapped_coord_sorted.sam > cleaned.sam

  # Sort by name
  samtools sort \
  -@ \$SLURM_CPUS_ON_NODE \
  -n \
  -o cleaned_name_sorted.sam \
  cleaned.sam

  # Convert to fastq
  if [[ "${read2}" == "mock.trim.fastq" ]]
  then

    samtools fastq \
    -@ \$SLURM_CPUS_ON_NODE \
    cleaned_name_sorted.sam > ${sample_id}_cleaned_R1.fq

    # Adding mock read2 output
    touch mock.clean.fastq

    gzip ${sample_id}_cleaned_R1.fq

  else

    samtools fastq \
    -@ \$SLURM_CPUS_ON_NODE \
    -1 ${sample_id}_cleaned_R1.fq \
    -2 ${sample_id}_cleaned_R2.fq \
    cleaned_name_sorted.sam

    gzip ${sample_id}_cleaned_R1.fq
    gzip ${sample_id}_cleaned_R2.fq

  fi
  """

}