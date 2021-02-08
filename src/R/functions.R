#!/usr/bin/env R

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                                                                              #
# functions.R                                                                  #
#                                                                              #
# By: Maud Gautier <https://github.com/MaudGautier>, 2021                      #
#                                                                              #
# Broad permissions are granted to use, modify, and distribute this software   #
# as specified in the MIT License included in this distribution's LICENSE file.#
#                                                                              #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# This script contains the functions required to plot figures.


# Create TSS to ChIP distance plot ----------------------------------------
draw_TSS_to_ChIP_distance <- function(data_plot, 
                                      plot_name, 
                                      name_neotranscripts,
                                      col1="pink", col2 = "lightblue") {
  
  # Open output file
  png(paste0(plot_name), width = 595*2, height = 530*2)

  # Plot file
  print(ggplot() +                       
    geom_histogram(aes(x=log, y=..count.., fill = col1), position = "identity", alpha = 0.7, bins = 50, data = data_plot[which(data_plot$group == "All"),]) + 
    geom_histogram(aes(x=log, y=..count..*ratio, fill = col2), position = "identity", alpha = 0.7, bins = 50, data = data_plot[which(data_plot$group == name_neotranscripts),]) + 
    scale_x_continuous()  +
    scale_y_continuous(sec.axis = sec_axis(~.*1/ratio,
                                           name = paste("#", name_neotranscripts, "neotranscripts (blue)")), position="right") +
    labs(y = lab_y,
         x = lab_x) +
    theme_classic() +
    theme(text=element_text(size=20),
          legend.position = c(0.2, 0.9), legend.key.size = unit(1, 'lines'),
          axis.title.y.right = element_text(margin = margin(l = 10, r = 10)),
          axis.title.y = element_text(margin = margin(l = 10, r = 10))) +
    scale_fill_identity(guide = "legend", name="Transcript category",
                        breaks = c(col1, col2), labels = c("hg19 transcripts", paste(name_neotranscripts, "neotranscripts"))))
  
  # Close file
  dev.off()
}

