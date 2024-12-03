#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
INSERT PIPELINE DESCRIPTION
*/

// ----------------Workflow---------------- //

include { GENERATEKRAKEN2DB } from './workflows/kraken2_db_prep.nf'
include { KRAKEN2 } from './workflows/kraken2_run.nf'

workflow {

  if (params.prep_db) {
    
    GENERATEKRAKEN2DB()

  }

  if (params.get_taxonomy) {

    KRAKEN2()

  }

}