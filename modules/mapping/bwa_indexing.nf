process BwaIndex {

  // Generate a BWA index

  label 'mapping'

  publishDir "${projectDir}/bwa_index", mode: "copy", pattern: "*.{amb,ann,bwt,pac,sa}"

  input:
  path fasta

  output:
  path "*.{amb,ann,bwt,pac,sa}", emit: bwa_index

  """
  bwa index ${fasta}
  """

}
