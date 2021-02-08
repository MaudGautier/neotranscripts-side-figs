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

# Config plot to get the TSS to ChIP peak distances.



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

# Output
output_dir=/data/kdi_prod/project_result/726/27.01/results/tests_distances
TSS_file=${output_dir}/TSS_EwS_FLI1_neotranscripts.txt
ChIP_EwS_FLI1_with_GGAA=${output_dir}/intersect_EwS_FLI1_ChIP_peaks_with_more_than_4_GGAA_repeats.txt


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                  Plot logos                                  #
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
	-o ${ChIP_EwS_FLI1_with_GGAA}


