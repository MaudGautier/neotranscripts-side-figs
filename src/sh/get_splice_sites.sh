#!/usr/bin/env sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                                                              #
# get_splice_sites.sh                                                          #
#                                                                              #
# By: Maud Gautier <https://github.com/MaudGautier>, 2021                      #
#                                                                              #
# Broad permissions are granted to use, modify, and distribute this software   #
# as specified in the MIT License included in this distribution's LICENSE file.#
#                                                                              #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

## Description
# Extracts the bases positioned at donor and acceptor splice sites.
# A donor splice site corresponds to the 2 nucleotides at the 5' end of an
# intron and an acceptor splice site corresponds to the 2 nucleotides at the 3'
# end of an intron.
# 
# Example (Forward direction):
#   5'                                                               3'
#     EXON1    |    INTRON    |    EXON2    |    INTRON    |    EXON3
#   5'          GT          AG               gt          ag          3'
#               ^^          ^^               ^^          ^^
#           EXON1-RIGHT  EXON2-LEFT      EXON2-RIGHT  EXON3-LEFT
# ->          donor=GT     acc=AG           donor=gt    acc=ag
#
#
# Example (Backward direction):
#   3'                                                               5'
#     EXON1    |    INTRON    |    EXON2    |    INTRON    |    EXON3
#   5'          CT          AC               ct          ac          3'
#   3'          GA          TG               ga          tg          5'
#               ^^          ^^               ^^          ^^
#           EXON1-RIGHT  EXON2-LEFT      EXON2-RIGHT  EXON3-LEFT
# ->          acc=AG      donor=GT        acc=ag        donor=gt
#


## Usage
# sh ./src/sh/get_splice_sites.sh \
	# [-f <FORMAT>] \
	# -i <GTF_FILE> \
	# -o <OUTPUT_PREFIX> \
	# -r <REF_FASTA>



## Requirements
# - GNU awk
# - GNU grep
# - bedtools
# - weblogo




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                              PARAMETERS                               ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Default value for format
format="eps"

while [[ $# -gt 1 ]]
do
    key="$1"

    case $key in
        -i|-g)
            gtf_file="$2"
            shift
            ;;
        -o)
            output_prefix="$2"
            shift
            ;;
        -r|--ref)
            ref_fa="$2"
            shift
            ;;
        -f|--format)
            format="$2"
            shift
            ;;
        *)
            # unknown option
            ;;
    esac
    shift # past argument or value
done

echo GTF FILE        = "${gtf_file}"
echo REF FASTA       = "${ref_fa}"
echo OUTPUT PREFIX   = "${output_prefix}"
echo OUTPUT FORMAT   = "${format}"




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                           GET SPLICE SITES                            ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# To have 5 nucleotides on each side:
# Acceptor: print prev_chrom, prev_3prime_start-5, prev_3prime_start+7, prev_transcript"/exon"prev_exon"/right", 1, prev_strand
# Donor: print $1, $4-8, $4+4, transcript"/exon"exon"/left", 1, $7


find_logo_splice_sites_from_gtf() 
{
	# Function parameters
	gtf_file=$1
	output_prefix=$2
	ref_hg19=$3 
	
	# Define other parameters
	bed_file=${output_prefix}.bed
	fasta_file=${output_prefix}.fa
	
	# 1. Create bed file
	awk -v FS="\t" -v OFS="\t" '$3=="exon" {
		split($9, a, " ") 
		
		gsub("\"","",a[4]) 
		gsub(";", "", a[4])
		transcript = a[4]
		
		gsub("\"", "", a[6])
		gsub(";", "", a[6])
		exon = a[6]
		
		if (transcript == prev_transcript) {
			print prev_chrom, prev_3prime_start-5, prev_3prime_start+7+15, prev_transcript"/exon"prev_exon"/right", 1, prev_strand
			print $1, $4-8-15, $4+4, transcript"/exon"exon"/left", 1, $7
		} 

		prev_transcript = transcript
		prev_exon = exon
		prev_chrom = $1
		prev_3prime_start = $5
		prev_strand = $7
	}' ${gtf_file} > ${bed_file}


	# 2. Get fasta sequences
	bedtools getfasta -fi ${ref_hg19} \
		-bed ${bed_file} \
		-name -s \
		> ${fasta_file}_TMP0


	# 3. Get counts from fasta sequences
	sed 's/right(+)/right(+)\/donor/g' ${fasta_file}_TMP0 > ${fasta_file}_TMP1
	sed 's/right(-)/right(-)\/acceptor/g' ${fasta_file}_TMP1 > ${fasta_file}_TMP2
	sed 's/left(-)/left(-)\/donor/g' ${fasta_file}_TMP2 > ${fasta_file}_TMP3
	sed 's/left(+)/left(+)\/acceptor/g' ${fasta_file}_TMP3 > ${fasta_file}
	rm -f ${fasta_file}_TMP*

}

add_acceptors() { 
	in_file=$1
	out_file=$2
	if [ -f ${out_file} ] ; then rm -f ${out_file} ; fi
	grep -A 1 acceptor ${in_file} | grep -v "^--" - | \
		sed -e 's/T/U/g' | sed 's/t/u/g' | sed 's/uum/tum/g' | sed 's/righu/right/g' | sed 's/lefu/left/g' | sed 's/DSRCU/DSRCT/g' | sed 's/NFAU/NFAT/g' | sed
	's/PAUZ1/PATZ1/g' | sed 's/SFU/SFT/g' | sed 's/UFE3/TFE3/g' | sed 's/accepuor/acceptor/g' \
		>> ${out_file}
}

add_donors() { 
	in_file=$1
	out_file=$2
	if [ -f ${out_file} ] ; then rm -f ${out_file} ; fi
	grep -A 1 donor ${in_file} | grep -v "^--" - | \
		sed -e 's/T/U/g' | sed 's/t/u/g' | sed 's/uum/tum/g' | sed 's/righu/right/g' | sed 's/lefu/left/g' | sed 's/DSRCU/DSRCT/g' | sed 's/NFAU/NFAT/g' | sed 's/PAUZ1/PATZ1/g' | sed 's/SFU/SFT/g' | sed 's/UFE3/TFE3/g' \
		>> ${out_file}
}




# Get splice site fasta files
find_logo_splice_sites_from_gtf ${gtf_file} ${output_prefix} ${ref_fa}

# Distinguish acceptor sites
add_acceptors ${output_prefix}.fa ${output_prefix}_ACCEPTORS.fa

# Distinguish donor sites
add_donors ${output_prefix}.fa ${output_prefix}_DONORS.fa

# Make logos
weblogo -F $format < ${output_prefix}"_ACCEPTORS.fa" > ${output_prefix}"_ACCEPTORS."${format}
weblogo -F $format < ${output_prefix}"_DONORS.fa" > ${output_prefix}"_DONORS."${format}



