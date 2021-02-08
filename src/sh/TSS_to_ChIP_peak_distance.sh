#!/usr/bin/env sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                                                              #
# TSS_to_ChIP_peak_distance.sh                                                 #
#                                                                              #
# By: Maud Gautier <https://github.com/MaudGautier>, 2021                      #
#                                                                              #
# Broad permissions are granted to use, modify, and distribute this software   #
# as specified in the MIT License included in this distribution's LICENSE file.#
#                                                                              #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Script to calculate the TSS to ChIP summit distance

## Usage
# sh ./src/sh/TSS_to_ChIP_peak_distance.sh \
	# -i <GTF_FILE> \
	# -o <OUTPUT_FILE> \
	# -t <TEMP_DIR> \
	# -s <CHIP_SUMMIT_FILE>


## Requirements
# GNU awk


## Input
# The input ChIP summit file must be a 3-column file with chrom, position and 
# ID of the ChIP peak summit.
# E.g.:
# chr1  7918141   id-74404
# chr1  7918170   id-74406
# chr1  8665638   id-81068
# chr1  8665682   id-81069
# chr1  11048479  id-101761


## Output
# The TSS file contains three columns: chrom, position, transcript_ID
# Each line gives the position of the TSS for any given transcript ID.
# E.g.:
# chr10 19206483	Ew_NG4.5
# chr10 19206483	Ew_NG4.2
# chr10 19206483	Ew_NG4.3
# chr10 19206483	Ew_NG4.1
# chr10 19206483	Ew_NG4.4
#
# The final output file contains the following 6 columns:
# transcript_id, ChIP_ID, chrom, TSS_pos, ChIP_summit_pos, distance_TSS_to_ChIP_summit
# E.g.: 
# Ew_NG1.1   id-708686    chr1  73171083   73172023   940
# Ew_NG2.2   id-11590019  chr2  4633146    4633957    811
# Ew_NG2.3   id-11590020  chr2  4634024    4633977    47
# Ew_NG2.1   id-11590146  chr2  4795659    4645687    149972
# Ew_NG26.1  id-12831412  chr2  133035142  133035795  653




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                              PARAMETERS                               ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Get directory path (to call other scripts)
src_dir=`dirname $0`

while [[ $# -gt 1 ]]
do
	key="$1"

	case $key in
		-i|-g)
			gtf_file="$2"
			shift
			;;
		-o)
			output_file="$2"
			shift
			;;
		-t|--temp)
			temp_dir="$2"
			shift
			;;
		-s|--summits)
			ChIP_summits="$2"
			shift
			;;
		*)
			# unknown option
			;;
	esac
	shift # past argument or value
done

echo GTF FILE        = "${gtf_file}"
echo OUTPUT FILE     = "${output_file}"
echo TEMP DIR        = "${temp_dir}"
echo ChIP SUMMITS    = "${ChIP_summits}"




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                                OUTLINE                                ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Temporary files and folders
TSS_file=${temp_dir}/TSS.txt
folder_TSS=${temp_dir}/TSS_per_chromosome
folder_ChIP=${temp_dir}/ChIP_summits_per_chromosome
if [ ! -d $temp_dir ] ; then mkdir -p $temp_dir ; fi


# Step 1: Prepare the TSS file
awk -v OFS="\t" -v FS="\t" '
$3=="transcript" {
	split($9, a, ";")
	split(a[2], b, "\"")
	if ($7 == "-") {
		print $1, $5, b[2]
	} else if ($7 == "+") {
		print $1, $4, b[2]
	}
}' ${gtf_file} > $TSS_file


# Step 2: Divide TSS file per chromosome
if [ -d $folder_TSS ] ; then rm -rf $folder_TSS ; fi
if [ ! -d $folder_TSS ] ; then mkdir $folder_TSS ; fi
awk -v OUTFOLDER=$folder_TSS '{print $0>OUTFOLDER"/"$1".txt"}' $TSS_file


# Step 3: Divide ChIP summits file per chromosome
if [ -d $folder_ChIP ] ; then rm -rf $folder_ChIP ; fi
if [ ! -d $folder_ChIP ] ; then mkdir $folder_ChIP ; fi
awk -v OUTFOLDER=$folder_ChIP '{print $0>OUTFOLDER"/"$1".txt"}' $ChIP_summits


# Step 4: Get closest TSS site from each ChIP peak
list_chromosomes=(
chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 
chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 
chr21 chr22 chrX)
if [ ! -z ${output_file}_TMP ]; then rm -f ${output_file}_TMP ; fi
for chrom in ${list_chromosomes[@]} ; do
	if [ -f $folder_TSS/${chrom}.txt ] && [ -f $folder_ChIP/${chrom}.txt ] ; then
		awk -f ${src_dir}/closest.awk \
			$folder_TSS/${chrom}.txt \
			$folder_ChIP/${chrom}.txt \
			>> ${output_file}_TMP
	fi
done

# Calculate distance
awk -v OFS="\t" '
{
	if ($5-$2 >= 0) { dist=$5-$2 
	} else { dist=$2-$5 } 
	print $6, $3, $1, $5, $2, dist
}' ${output_file}_TMP \
	> ${output_file}

# Delete temporary files and folders
rm -f ${output_file}_TMP
rm -rf $temp_dir


