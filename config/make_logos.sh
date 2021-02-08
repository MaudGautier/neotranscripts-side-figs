#!/usr/bin/env sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                                                              #
# make_logos.sh                                                                #
#                                                                              #
# By: Maud Gautier <https://github.com/MaudGautier>, 2021                      #
#                                                                              #
# Broad permissions are granted to use, modify, and distribute this software   #
# as specified in the MIT License included in this distribution's LICENSE file.#
#                                                                              #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Config plot to create logos.



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                  Parameters                                  #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Generic parameters
output_dir=/data/kdi_prod/project_result/726/27.01/results/tests_logo
if [ ! -d $output_dir ] ; then mkdir $output_dir ; fi
output_prefix=${output_dir}/201201_list_neos_logo_splice_site
ref_hg19=/data/annotations/pipelines/Human/hg19/genome/hg19.fa
format=png
gtf_file=/data/kdi_prod/project_result/726/27.01/results/1_Data/201201_list_neos.gtf
stat_file=${output_prefix}_STATS.txt


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                  Plot logos                                  #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

sh ./src/sh/get_splice_sites.sh \
		-i $gtf_file \
		-o $output_prefix \
		-f $format \
		-r $ref_hg19



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                      Get number of sites per tumor type                      #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

list_tumors=($(awk '{print $10}' $gtf_file | cut -d"_" -f1 | sed 's/\"//' |uniq))

echo "#Nb exon-intron junctions" > $stat_file
for tum_type in ${list_tumors[@]} ; do
	nb=`grep $tum_type ${output_prefix}.fa | wc -l`
	echo -e $tum_type"\t"$nb >> $stat_file
done


