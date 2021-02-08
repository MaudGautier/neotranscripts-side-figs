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

# Config file to generate TSS to ChIP peak distance plots.



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                  Parameters                                  #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Output
plot_name <- "./plots/aRMS_distance.png"
name_neotranscripts <- "aRMS"
lab_x <- "Distance between TSS and closest PAX-FOFO ChIP peak (log-scale)"
lab_y <- "# hg19 transcripts (pink)"
ratio <- 15000/6
col1 <- "pink"
col2 <- "lightblue"

# Input data
neotranscripts_distance <- "./data/Closest_TSS_from_PF_ChIP_peak_for_aRMS_neotranscripts.txt"
hg19_distance <- "./data/Closest_TSS_from_PF_ChIP_peak_for_all_hg19_transcripts.txt"

# Main folder (i.e. where the github repo is)
main_folder <- "./"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                   Read data                                  #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Import packages
library(ggplot2)
source(file.path(main_folder, "src/R/functions.R"))

# Read data
neos <- read.table(neotranscripts_distance)
hg19 <- read.table(hg19_distance)

# Create data frame
data_plot <- data.frame(values = c(unique(neos$V6), 
								   unique(hg19$V6)),
                        group = c(rep(name_neotranscripts, length(unique(neos$V6))),
                                  rep("All", length(unique(hg19$V6)))))

# Get log10 information
data_plot$log <- log10(data_plot$values)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                  Create plot                                 #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

draw_TSS_to_ChIP_distance(data_plot, 
						  plot_name, 
						  name_neotranscripts,
						  lab_x, lab_y,
						  ratio,
						  col1, col2)



