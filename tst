
    if url.endswith('gz'):
        """
        wget -O - ${url} | gunzip -c > $params.count_matrix
        """
    else:
        """
        wget -O - ${url} | tar -zxf > $params.raw_reads
        """