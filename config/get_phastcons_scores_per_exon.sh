#!/usr/bin/env sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                                                              #
# get_phastcons_scores_per_exon.sh                                             #
#                                                                              #
# By: Maud Gautier <https://github.com/MaudGautier>, 2021                      #
#                                                                              #
# Broad permissions are granted to use, modify, and distribute this software   #
# as specified in the MIT License included in this distribution's LICENSE file.#
#                                                                              #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Script to calculate the phastcons scores of all exons.

## Requirements
# - GNU awk
# - GNU sort
# - GNU grep
# - bigWigToBedGraph
# - bedtools
# - java



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                               PARAMETERS                              ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Input files
ref_genome="/data/annotations/pipelines/Human/hg19/genome/hg19.fa"
gtf_file=/data/kdi_prod/project_result/726/27.01/results/1_Data/201201_list_neos.gtf
hg19_gtf_file=/data/annotations/pipelines/Human/hg19/gtf/gencode.v19.annotation.sorted.gtf

# Output files
output_dir=/data/kdi_prod/project_result/726/27.01/results/tests_phastcons
exons=$output_dir/exons.bed
hg19_exons=$output_dir/hg19_exons.bed
per_category_dir=$output_dir/per_category_scores
per_exon_dir=$output_dir/per_exon_scores
if [ ! -d $per_category_dir ] ; then mkdir $per_category_dir ; fi
if [ ! -d $per_exon_dir ] ; then mkdir $per_exon_dir ; fi
output_annots=$output_dir/gencode.v19.annotation_jvarkit.txt

# Where jvarkit has been installed (see README)
JVARKIT_DIST=~/bin/jvarkit/dist



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                               FUNCTIONS                               ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

get_exons() {
	in_file=$1
	out_file=$2
	awk -v FS="\t" -v OFS="\t" '
	$3=="exon" {
		split($9, a, ";")
		split(a[2], b, " ")
		split(a[3], c, " ")
		gsub("\"","",b[2])
		gsub("\"","",c[2])
		print $1, $4, $5, b[2]"-"c[2]
	}'  ${in_file} \
		| sort -k1,1 -k2,2n \
		> $out_file
}

get_score_per_exon() {
	in_file=$1
	out_file=$2
	awk -v OFS="\t" '
	{
		score[$8] += ($3-$2+1)*$4
		le[$8]+=$3-$2+1
	}
	END { for (exon in score) {
		print exon, score[exon]/le[exon]
	} }' $in_file > $out_file
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                           EXECUTE PROCEDURE                           ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# 1. Get phastcons score file
cd $output_dir
wget http://hgdownload.cse.ucsc.edu/goldenpath/hg19/phastCons100way/hg19.100way.phastCons.bw

# 2. Transform to bed format (via bedgraph)
bigWigToBedGraph $output_dir/hg19.100way.phastCons.bw $output_dir/hg19.100way.phastCons.bedgraph

# 3. Get exons from GTF file
get_exons ${gtf_file} ${exons}
get_exons ${hg19_gtf_file} ${hg19_exons}

# 4. Intersect with exons
bedtools intersect -wb \
	-a $output_dir/hg19.100way.phastCons.bedgraph \
	-b $hg19_exons \
	> $output_dir/hg19.100way.phastCons.against_exons.bed
bedtools intersect -wb \
	-a $output_dir/hg19.100way.phastCons.bedgraph \
	-b $exons \
	> $output_dir/hg19.100way.phastCons.against_neotranscript_exons.bed

# 5. Divide per category
awk -v FOLDER=$per_category_dir '
{ 
	split($8,a,"-") 
	print $0 > FOLDER"/"a[2]
}' $output_dir/hg19.100way.phastCons.against_exons.bed

# 6. Get score per exon
for type_exon in lincRNA protein_coding ; do
	echo $type_exon
	file=$per_category_dir/$type_exon
	get_score_per_exon $file $per_exon_dir/${type_exon}.txt
done
get_score_per_exon $output_dir/hg19.100way.phastCons.against_neotranscript_exons.bed $per_exon_dir/neotranscripts.txt

# 7. Extract UTR annotations for protein coding genes
java -jar $JVARKIT_DIST/bioalcidaejdk.jar \
	-F GTF \
	-f ./src/sh/biostar.code \
	$hg19_gtf_file \
	> $output_annots
grep UTR $output_annots | cut -f5|cut -d" " -f4|uniq > $output_dir/UTRs.txt
grep UTR $output_annots > $output_dir/UTRs.bed
grep -f $output_dir/UTRs.txt \
	$per_category_dir/protein_coding \
	> $per_category_dir/protein_coding_with_UTR

# 8. Get score per exon outside UTR
bedtools intersect -v \
	-a $per_category_dir/protein_coding_with_UTR \
	-b $output_dir/UTRs.bed \
	> $per_category_dir/protein_coding_outside_UTR.txt
get_score_per_exon $per_category_dir/protein_coding_outside_UTR.txt $per_exon_dir/protein_coding_outside_UTR.txt


