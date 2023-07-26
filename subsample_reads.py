#!/bin/python3
"""
This script will take fastq file and split it into several subsamples, which will be easier to use as a test files for the workflow
It will split fastq in batches and randomly add reads into number of user-defined mock read files
"""
import sys
import gzip
import random
import argparse

# Initialize parser
parser = argparse.ArgumentParser()

# Adding optional arguments
parser.add_argument("-r", "--reads", help="Read path")
parser.add_argument("-n", "--num_samples", help="Number of samples")
parser.add_argument("-p", "--sample_path", help="Where to put generated subsamples")
parser.add_argument("-pr", "--prefix", help="Prefix for subsamples")
parser.add_argument("-pf", "--postfix", help="Postfix for subsamples")


# Read arguments from command line


class SplitReads:
    def __init__(self, args):
        print(args)
        self.read_path = args.reads
        self.numb = int(args.num_samples)
        self.sam_path = args.sample_path
        self.prefix = args.prefix
        self.postfix = args.postfix
        self.file_list = dict()
        self.file_list = self.create_files(self.numb, self.sam_path)
        self.iterate_and_write(self.read_path, self.file_list, self.numb)

    def create_files(self, number_of_samples, sample_path):
        for sample_item in range(number_of_samples):
            filename = f'{sample_path}/{self.prefix}_{sample_item}_{self.postfix}.fastq'
            new_file = open(filename, 'w')
            new_file.close()
            self.file_list[sample_item] = filename
        return self.file_list

    def get_next_read(self, reads):
        new_read_row = []
        for i in range(0, 4):
            new_read_row.append(next(reads).decode("utf-8"))
        print(new_read_row)
        return new_read_row

    def write_random_file(self, reads):
        next_read = self.get_next_read(reads)
        print(next_read)
        lucky_sample_file = random.randrange(self.numb)
        lucky_file = self.file_list[lucky_sample_file]
        with open(lucky_file, 'a') as f:
            f.writelines("".join(next_read))
            f.close()

    def iterate_and_write(self, read_path, file_list, number_of_samples):
        with gzip.open(read_path, 'rb') as reads:
            while True:
                self.write_random_file(reads)
            return 'Looks like we are done'


if __name__ == '__main__':
    args = parser.parse_args()
    SplitReads(args)
