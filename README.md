# neotranscripts-side-figs

This repo contains the scripts for some side analyses of the neotranscripts project, including:

* scripts to create logos of donor and acceptor splice sites;
* 


## Usage

**Clone the repo**

Clone the repository with this command line:
```
git clone https://github.com/MaudGautier/neotranscripts-side-figs.git ./
cd ./neotranscripts-side-figs
```

**Make logos of donor and acceptor splice sites**
Prepare a configuration file in a similar fashion to the [``config/make_logos.sh`` file](https://github.com/MaudGautier/neotranscripts-side-figs/tree/main/config/make_logos.sh) and executing it using this command line:
```
sh ./config/make_logos.sh
```

**Get TSS-to-ChIPpeak distances**
To get the data, prepare a configuration file in a similar fashion to the [``config/TSS_to_ChIP_peak_distance_for_DSRCT.sh`` file](https://github.com/MaudGautier/neotranscripts-side-figs/tree/main/config/TSS_to_ChIP_peak_distance_for_DSRCT.sh) and execute it using this command line:
```
sh ./config/TSS_to_ChIP_peak_distance_for_DSRCT.sh
```

Then, to plot the figure, prepare a configuration file in a similar fashion to the [``config/plot_TSS_to_ChIP_peak_distance_for_DSRCT.R`` file](https://github.com/MaudGautier/neotranscripts-side-figs/tree/main/config/plot_TSS_to_ChIP_peak_distance_for_DSRCT.R) and execute it using this command line:
```
sh ./config/config/plot_TSS_to_ChIP_peak_distance_for_DSRCT.R
```

**Phastcons scores**
Running the phastCons score calculation requires the installation of the jvarkit tool by following this procedure:
```
# Install jvarkit - bioalcidaejdk
cd ~/bin/
git clone "https://github.com/lindenb/jvarkit.git"
cd jvarkit
./gradlew bioalcidaejdk
```

Then, modify parameters and execute the [``config/get_phastcons_scores_per_exon.sh`` file](https://github.com/MaudGautier/neotranscripts-side-figs/tree/main/config/get_phastcons_scores_per_exon.sh) using this command line:
```
sh ./config/get_phastcons_scores_per_exon.sh
```



## Requirements

The following applications must be installed: 

* GNU bash, version 4.2.46
* GNU Awk, version 4.0.2
* GNU grep, version 2.20
* bedtools, version 2.27.1
* weblogo, version 3.6.0
* R, version 4.0.3
* jvarkit bioalcidaejdk

To plot figures, the `ggplot2` package must be installed in R.



