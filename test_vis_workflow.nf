#!/usr/bin/env nextflow

params.in = "$baseDir/data/sample.fa"
params.out = "$baseDir/data/align.fa"
/*
 * Split a fasta file into multiple files
 */
process splitSequences {

    input:
    path 'input.fa'

    output:
    path 'seq_*'

    """
    awk '/^>/{f="seq_"++d} {print > f}' < input.fa
    """
}

/*
 * Reverse the sequences
 */
process reverse {

    input:
    path x

    output:
    stdout

    """
    cat $x | rev
    """
}
process alignSequences {

    shell
    """
    muscle -align $params.in -output $params.out
    """
}

/*
 * Draw pics
 */
process pyTask {
    input:
    stdin

    output:
    stdout

    """
    #!/usr/bin/env python
    import plotly.express as px
    df = px.data.tips()
    fig = px.histogram(df, x="total_bill")
    fig.write_html("$baseDir/out/test_vis.html")
    """
}



/*
 * Define the workflow
 */
workflow {
    alignSequences
    splitSequences(params.in) \
      | reverse \
      | pyTask \
      | view
}