#!/usr/bin/env sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                                                              #
# TSS_to_ChIP_peak_distance_for_DSRCT.sh                                       #
#                                                                              #
# By: Maud Gautier <https://github.com/MaudGautier>, 2021                      #
#                                                                              #
# Broad permissions are granted to use, modify, and distribute this software   #
# as specified in the MIT License included in this distribution's LICENSE file.#
#                                                                              #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Config plot to get the TSS to ChIP peak distances for DSRCT neotranscripts.



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                  Parameters                                  #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Generic parameters
# Input
input_dir=/data/kdi_prod/project_result/726/27.01/results/1_Data/
chrom_sizes_hg19=/data/annotations/pipelines/Human/hg19/genome/chrom_hg19.sizes
chrom_sizes_sorted=${input_dir}/chrom_hg19.sizes.sorted
ChIP_peaks_file=/data/kdi_prod/project_result/726/27.03/results/4_Macs/ChIP-EWS-WT1_ChIP-EWS-WT1-INPUT_0.05_peaks_NO_BLACKLIST.narrowPeak
gtf_file=/data/kdi_prod/project_result/726/27.03/results/1_Data/200624_DSRCT_neos_NEW_IDs.gtf
hg19_gtf_file=/data/annotations/pipelines/Human/hg19/gtf/gencode.v19.annotation.sorted.gtf

# Output
output_dir=/data/kdi_prod/project_result/726/27.01/results/tests_distances
temp_dir=${output_dir}/temp
ChIP_summits=${output_dir}/EwS_WT1_ChIP_peaks_summits.txt



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                          Prepare ChIP summit files                           #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# (Optional) Sort chrom sizes in correct order
if [ ! -f $chrom_sizes_sorted   ] ; then
	grep "chr[123456789]" ${chrom_sizes_hg19} | grep -v random | grep -v hap \
		> ${chrom_sizes_sorted}
	grep "chrM" ${chrom_sizes_hg19} >> ${chrom_sizes_sorted}
	grep "chr[XY]" ${chrom_sizes_hg19} >> ${chrom_sizes_sorted}
fi

# Get ChIP peak summit
awk -v OFS="\t" '{print $1, $2+$10, $4}' ${ChIP_peaks_file} \
	> ${ChIP_summits}




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#             Get TSS to ChIP peak distance for EwS neotranscripts             #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Get TSS to EwS_FLI1 ChIP peak distance for EwS neotranscripts
output_file=${output_dir}/Closest_TSS_from_EwS_WT1_ChIP_peak_for_EwS_neotranscripts.txt
sh ./src/sh/TSS_to_ChIP_peak_distance.sh \
	-i $gtf_file \
	-o $output_file \
	-t $temp_dir \
	-s $ChIP_summits


# Get TSS to EwS_FLI1 ChIP peak distance for all hg19 transcrips
output_file=${output_dir}/Closest_TSS_from_EwS_WT1_ChIP_peak_for_all_hg19_transcripts.txt
sh ./src/sh/TSS_to_ChIP_peak_distance.sh \
	-i $hg19_gtf_file \
	-o $output_file \
	-t $temp_dir \
	-s $ChIP_summits



