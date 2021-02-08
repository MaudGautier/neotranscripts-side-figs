#!/usr/bin/env sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                                                              #
# TSS_to_ChIP_peak_distance_for_EwS.sh                                         #
#                                                                              #
# By: Maud Gautier <https://github.com/MaudGautier>, 2021                      #
#                                                                              #
# Broad permissions are granted to use, modify, and distribute this software   #
# as specified in the MIT License included in this distribution's LICENSE file.#
#                                                                              #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Config plot to get the TSS to ChIP peak distances for EwS neotranscripts.



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                  Parameters                                  #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Generic parameters
# Input
input_dir=/data/kdi_prod/project_result/726/27.01/results/1_Data/
chrom_sizes_hg19=/data/annotations/pipelines/Human/hg19/genome/chrom_hg19.sizes
chrom_sizes_sorted=${input_dir}/chrom_hg19.sizes.sorted
EwS_FLI1_ChIP_peaks_file=${input_dir}/A561C1/A561C1_A449C182_narrow_peaks.narrowPeak_clean.bed
GGAA_bed_file=${input_dir}/hg19_GGAA_TTCC_20151221.sorted.bed
EwS_gtf_file=/data/kdi_prod/project_result/726/27.01/results/1_Data/201201_Ewing_neos_NEW_IDs.gtf
hg19_gtf_file=/data/annotations/pipelines/Human/hg19/gtf/gencode.v19.annotation.sorted.gtf

# Output
temp_dir=${output_dir}/temp
output_dir=/data/kdi_prod/project_result/726/27.01/results/tests_distances
EwS_FLI1_ChIP_peaks=${output_dir}/EwS_FLI1_ChIP_peaks_with_more_than_4_GGAA_repeats.txt
EwS_FLI1_ChIP_summits=${output_dir}/EwS_FLI1_ChIP_peaks_with_more_than_4_GGAA_repeats_SUMMITS.txt



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


# Get ChIP peaks associated to 4 GGAA repeats
sh ./src/sh/get_ChIP_peaks_associated_to_4GGAA_repeats.sh \
	--gs ${chrom_sizes_sorted} \
	-i ${EwS_FLI1_ChIP_peaks_file} \
	--bed ${GGAA_bed_file} \
	-o ${EwS_FLI1_ChIP_peaks}

# Get ChIP peak summit
# NB: the summit is 1000 bp from the start because in the script called
# ./src/sh/get_ChIP_peaks_associated_to_4GGAA_repeats.sh, the 4GGAA repeats are
# searched in 1000 bp before and 1000 bp after the ChIP peak summit.
awk -v OFS="\t" '{print $1, $2+1000, $4}' ${EwS_FLI1_ChIP_peaks} \
	> ${EwS_FLI1_ChIP_summits}




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#             Get TSS to ChIP peak distance for EwS neotranscripts             #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Get TSS to EwS_FLI1 ChIP peak distance for EwS neotranscripts
output_file=${output_dir}/Closest_TSS_from_EwS_FLI1_ChIP_peak_for_EwS_neotranscripts.txt
sh ./src/sh/TSS_to_ChIP_peak_distance.sh \
	-i $EwS_gtf_file \
	-o $output_file \
	-t $temp_dir \
	-s $EwS_FLI1_ChIP_summits


# Get TSS to EwS_FLI1 ChIP peak distance for all hg19 transcrips
output_file=${output_dir}/Closest_TSS_from_ChIP_peak_for_all_hg19_transcripts.txt
sh ./src/sh/TSS_to_ChIP_peak_distance.sh \
	-i $hg19_gtf_file \
	-o $output_file \
	-t $temp_dir \
	-s $EwS_FLI1_ChIP_summits



