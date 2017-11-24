"""Simple script for filtering STAR junction files
   for reads in a given (filtered) BAM file.
"""

import argparse
import logging

import pandas as pd
import pysam

FORMAT = "[%(asctime)-15s] %(message)s"
logging.basicConfig(
    format=FORMAT, level=logging.INFO, datefmt="%Y-%m-%d %H:%M:%S")


def main():
    """Main function."""

    args = parse_args()

    # Read querynames from filtered bam.
    logging.info('Reading querynames from bam file(s)')

    query_names = {}
    for bam_path in args.bam_files:
        with pysam.AlignmentFile(bam_path) as bam_file:
            query_names |= {aln.query_name for aln in bam_file}

    # Read and filter junctions.
    logging.info('Reading and filtering junctions')
    junctions = pd.read_csv(args.junctions, sep='\t', header=None)
    junctions = junctions.loc[junctions[9].isin(query_names)]

    # Write out filtered junctions.
    logging.info('Writing filtered junctions')
    junctions.to_csv(args.output, sep='\t', index=False, header=False)


def parse_args():
    """Parse command line arguments."""

    parser = argparse.ArgumentParser()

    parser.add_argument(
        '--junctions', required=True, help='Junction file to filter.')

    parser.add_argument(
        '--bam_files',
        required=True,
        nargs='+',
        help='Bam files to filter against.')

    parser.add_argument('--output', required=True)

    parser.add_argument(
        '--complement',
        default=False,
        action='store_true',
        help='Drop the reads in the given bam files instead of keeping them.')

    return parser.parse_args()


if __name__ == '__main__':
    main()
