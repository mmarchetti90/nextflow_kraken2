process Bracken {

  // Summarize Kraken2 report
  
  label 'kraken2'

  publishDir "${projectDir}/bracken_outputs", mode: "copy", pattern: "*.report"
  publishDir "${projectDir}/bracken_outputs", mode: "copy", pattern: "*.out"

  input:
  each rank_type
  each path(kraken_db)
  tuple val(sample_id), path(kraken_report)

  output:
  path "*.report", emit: bracken_reports
  path "*.out", emit: bracken_outputs

  """
  bracken \
  -d ${kraken_db} \
  -i ${kraken_report} \
  -o ${sample_id}_bracken-${rank_type}.out \
  -l ${rank_type} \
  -t ${params.bracken_threshold}
  """

}
