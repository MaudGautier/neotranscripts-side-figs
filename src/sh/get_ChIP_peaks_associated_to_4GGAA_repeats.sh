#!/usr/bin/env sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                                                              #
# get_ChIP_peaks_associated_to_4GGAA_repeats.sh                                #
#                                                                              #
# By: Maud Gautier <https://github.com/MaudGautier>, 2021                      #
#                                                                              #
# Broad permissions are granted to use, modify, and distribute this software   #
# as specified in the MIT License included in this distribution's LICENSE file.#
#                                                                              #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

## Description
# Script to extract ChIP peaks associated to (i.e. within 1kb of) a >= 4 GGAA 
# repeat (i.e. a sequence of GGAAGGAAGGAAGGAA).


## Usage
# sh ./src/sh/get_ChIP_peaks_associated_to_4GGAA_repeats.sh \
	# --gs <CHROM_SIZES> \
	# -i <INPUT_CHIP_FILE> \
	# --bed <GGAA_BED_REGIONS> \
	# -o <OUTPUT_FILE>


## Requirements
# - GNU grep
# - GNU sort
# - GNU awk
# - bedtools


## Input
# The input chrom_sizes should be in this form:
# chr1  249250621
# chr2  243199373
# chr3  198022430
# chr4  191154276
# chr5  180915260
# 
# The input ChIP file is in a BED format.
#
# The input GGAA bed regions file is also in a BED format.


## Output
# The output file is a BED file containing:
# columns 1-5: chrom, start, stop, name, number of GGAA repeats
# columns 6-9: chrom, start, stop, name of ChIP peak
# E.g.:
# chr1  7917141 7917157 id-74404    4 chr1  7916193 7918193 A561C1_A449C182_narrow_peak_28
# chr1  7917170 7917202 id-74406    8 chr1  7916193 7918193 A561C1_A449C182_narrow_peak_28
# chr1  8664638 8664658 id-81068    5 chr1  8663758 8665758 A561C1_A449C182_narrow_peak_43
# chr1  8664682 8664734 id-81069    13  chr1  8663758 8665758 A561C1_A449C182_narrow_peak_43
# chr1  11047479    11047519  id-101761 10  chr1  11047178  11049178  A561C1_A449C182_narrow_peak_62





# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                              PARAMETERS                               ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

while [[ $# -gt 1 ]]
do
    key="$1"

    case $key in
        -i)
            input_file="$2"
            shift
            ;;
        -o)
            output_file="$2"
            shift
            ;;
		-g|--gs)
            genome_sizes="$2"
            shift
            ;;
		-b|--bed)
            bed_regions="$2"
            shift
            ;;
        *)
            # unknown option
            ;;
    esac
    shift # past argument or value
done

echo GENOME SIZES    = "${genome_sizes}"
echo INPUT - BED     = "${input_file}"
echo OUTPUT FILE     = "${output_file}"
echo BED REGIONS     = "${bed_regions}"



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####          GET ChIP PEAKS ASSOCIATED TO 4 GGAA REPEATS OR MORE          ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Get BED +- 1kb of EwS-FLI1 ChIP-seq peak summits
awk -v OFS="\t" '{print $1, $2+$10-1000, $2+$10+1000, $4}' $input_file \
	| sort -k1,1V -k2,2V - \
	> ${input_file}_TMP_1kb_from_summit.bed

# Intersect with GGAA
bedtools intersect -split -wb \
	-sorted -g ${genome_sizes} \
	-a ${bed_regions} \
	-b ${input_file}_TMP_1kb_from_summit.bed \
	> ${input_file}_TMP_intersect_EwS_FLI1_ChIP_peaks_with_GGAA_in_1kb.txt

# Keep only ChIP peaks that have a >4 GGAA repeat
awk '$3-$2>=16 {print}' ${input_file}_TMP_intersect_EwS_FLI1_ChIP_peaks_with_GGAA_in_1kb.txt \
	> ${output_file}

# Delete temporary files
rm -f ${input_file}_TMP_*



