#!/usr/bin/env nextflow
nextflow.enable.dsl=2
params.count_matrix_gz = "$baseDir/data/count_matrix.tsv.gz"
params.count_matrix = "$baseDir/data/count_matrix.tsv"
params.raw_reads = "$baseDir/data/reads.fq"
params.url_count_matrix_original = "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE180nnn/GSE180237/suppl/GSE180237%5FMGH66%5FBulk%2Etsv%2Egz"
params.url_raw_data = "https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE180237&format=file"
params.scanpy_out = "$baseDir/out/bacter.h5ad"
/*
* download and unzip data for analysis https://ftp.ncbi.nlm.nih.gov/geo/series/GSE77nnn/GSE77288/suppl/GSE77288%5Fmolecules%2Draw%2Dsingle%2Dper%2Dsample%2Etxt%2Egz
*/

process dataAcquisition {

    debug true

    input:
    val url

    output:
    val params.count_matrix_gz

    script:

    """
    echo "here is $url"
    wget -O "$params.count_matrix_gz" $url
    echo 'loaded count matrix'
    """

}


process unzipData {
    debug true

    input:
    val gzipped_matrix

    output:
    val params.count_matrix


    script:
    """
    gunzip -c $gzipped_matrix > $params.count_matrix
    """

}


process plotExpression {
    input:
    val count_matrix

    debug true
    script:

    """
    #!/usr/bin/env python
    import numpy as np
    import pandas as pd
    import scanpy as sc
    results_file = "${params.scanpy_out}"
    adata = sc.read_text(
    "$count_matrix").T
    print(adata.var_names)
    print(adata)
    print(sc.pl.highest_expr_genes(adata, n_top=20, ))
    print(sc.pp.highly_variable_genes(adata))

    """

}

ch1 = Channel.of(params.url_count_matrix_original)
ch2 = Channel.of(params.count_matrix_gz)
workflow {
 dataAcquisition(ch1)|unzipData | plotExpression }

 //params.url_count_matrix_original(ch1)|dataAcquisition| unzipData | plotExpression| view