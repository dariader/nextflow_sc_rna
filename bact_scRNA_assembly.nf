#!/usr/bin/env nextflow
/*
*Alignments were performed using BWA51 and annotation of bam files were done using FeatureCounts.54
*/
NXF_WORK="${baseDir}/data/"
nextflow.enable.dsl=2
params.outdir = './out/'

process subsampleReads {

 publishDir pattern: "*.fastq", path: { params.outdir + "out/" }, mode: 'copy'

  input:
  path reads_file

  output:
  path "${baseDir}/out/"

  script:
  """

  #!/bin/bash
  ./subsample_reads.py

  """
}

process fastqc {

  input:
  path reads_file

  output:
  path 'fastqc'

  script:
  sample_id = 'test'
  """
  sample_id="test"
  mkdir -p fastqc
  fastqc -o fastqc -f fastq -q ${reads_file}

  """
}

process multiqc {
  publishDir params.outdir, mode:'copy'

  input:
  path('*')

  output:
   path('multiqc_report')

  script:
  """
  multiqc fastqc/.* -o multiqc_report
  """
}


process trimPolyA {

  input:
  path("${baseDir}/data/reads/.*")

  output:
  path("${baseDir}/out/trimmed_reads/")

  script:
  """
  mkdir -p multiqc_logs
  multiqc fastqc_.* -o ${baseDir}/multiqc_logs -t 8 --memory 4000
  """
}


workflow {
    reads = Channel
        .fromPath("$baseDir/out/mock_0_R1.fastq")
        .view()
    fastqc(reads)
    multiqc(fastqc.out.collect())
    }

