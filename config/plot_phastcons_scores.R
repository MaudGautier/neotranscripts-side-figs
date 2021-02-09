#!/usr/bin/env sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                                                              #
# plot_phastcons_scores.R                                                      #
#                                                                              #
# By: Maud Gautier <https://github.com/MaudGautier>, 2021                      #
#                                                                              #
# Broad permissions are granted to use, modify, and distribute this software   #
# as specified in the MIT License included in this distribution's LICENSE file.#
#                                                                              #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Config file to plot phastcons score histograms.



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                  Parameters                                  #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Input files
folder_phastcons_per_exon <- './data/per_exon_scores/'
cons_lincRNA_per_exon <- read.table(paste0(folder_phastcons_per_exon, 'lincRNA.txt'))
cons_protein_coding_OUT_UTR_per_exon <- read.table(paste0(folder_phastcons_per_exon, 'protein_coding_outside_UTR.txt'))
cons_neogenes_per_exon <- read.table(paste0(folder_phastcons_per_exon, 'neotranscripts.txt'))

# Graphical parameters
output_dir <- "./plots/"
width <- 595
height <- 530


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                 Create plots                                 #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Plot lincRNA
name <- "lincRNA"
png(file.path(output_dir, paste0(name, ".png")), width = width, height = height)
hist(cons_lincRNA_per_exon$V2, main = name, xlim = c(0,1), breaks = 20, xlab = "PhastCons score")
dev.off()

# Plot neotranscripts
name <- "Neotranscripts"
png(file.path(output_dir, paste0(name, ".png")), width = width, height = height)
hist(cons_neogenes_per_exon$V2, main = name, xlim = c(0,1), breaks = 20, xlab = "PhastCons score")
dev.off()

# Plot protein coding outside UTR
name <- "Prot_coding_outside_UTR"
png(file.path(output_dir, paste0(name, ".png")), width = width, height = height)
hist(cons_protein_coding_OUT_UTR_per_exon$V2, main = "Protein coding - exons w/o UTRs\n(subset 2000 transcripts)", xlim = c(0,1), breaks = 20, xlab = "PhastCons score")
dev.off()


