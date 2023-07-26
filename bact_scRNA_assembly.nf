#!/usr/bin/env nextflow
/*
*Alignments were performed using BWA51 and annotation of bam files were done using FeatureCounts.54
*/
NXF_WORK="${baseDir}/data/"
nextflow.enable.dsl=2

process fastqc {

 publishDir pattern: "*.html", path: { params.outdir + "fastp/" }, mode: 'copy'

  input:
  path reads_file

  output:
  path "${baseDir}/out/"

  script:
  sample_id = 'test'
  """
  sample_id="test"
  mkdir -p ${baseDir}/fastqc/${sample_id}_logs
  fastqc -o ${baseDir}/fastqc/${sample_id}_logs -f fastq -q ${reads_file}
  """
}

process multiqc {

  input:
  path("${baseDir}/fastqc/.*")

  output:
  path("${baseDir}/multiqc_logs")

  script:
  """
  mkdir -p multiqc_logs
  multiqc fastqc_.* -o ${baseDir}/multiqc_logs
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
        .fromPath("$baseDir/data/reads/*.fastq.gz")
        .view()
    fastqc(reads)
    fastqc_reports = Channel
        .fromPath("$baseDir/out/*_fastqc.zip")
        .view()
    multiqc(fastqc_reports)
    }

