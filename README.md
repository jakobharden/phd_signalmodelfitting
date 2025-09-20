# Information about the repository

## Title

**Signal model parameter optimisation for primary wave signal responses from ultrasonic pulse transmission tests - A numerical study concerning damped sinusoidal signals**.


## Abstract

In ultrasound signal analysis, the time range estimation plays an important role. The time range is the time span elapsing between the pulse excitation and the time when the sound wave hits the ultrasonic transducer. In the coherent literature, signal model fitting is addressed as one of the most accurate but also most costly methods to determine the sound wave's onset point, which is the upper limit of the time range.
In this study a signal model is fitted to the first ascending flank of the primary wave in order to detect the onset point and to parametrise the signal model. To show the broad applicability range, signals originating from ultrasonic pulse transmission tests (UPTM) on cement paste, ambient air, tap water and an aluminium cylinder are used.
A parameter variation based on that signal model allows for examining the signal model parameter's value ranges. Thereby, the fitting error is minimised using the least-squares method.
The results show that the signal model fits properly to a variety of primary wave signal responses, but not to all of them to the same degree.
To foster comprehensibility and reusability, all materials and results created in the course of this presentation are made available publicly under open licenses.


## Table of contents

- [License](#license)
- [Prerequisites](#prerequisites)
- [Directory and file structure](#directory-and-file-structure)
- [Installation instructions](#installation-instructions)
- [Usage instructions](#usage-instructions)
- [Help and Documentation](#help-and-documentation)
- [Related data sources](#related-data-sources)
- [Related software](#related-software)
- [Revision and release history](#revision-and-release-history)


## License

Copyright 2025 Jakob Harden (jakob.harden@tugraz.at, Graz University of Technology, Graz, Austria)

This file is part of the PhD thesis of Jakob Harden.

The following files are licensed under the *GNU AFFERO GENERAL PUBLIC LICENSE Version 3* (AGPLv3). See also licence information file "LICENSE".

- all \*.m files in directory: **/octave/aggregator**   
- all \*.m files in directory: **/octave/tools**   
- all */octave/algo\*.m* files   
- the file */octave/init.m*   

The following files are licensed under the *MIT* license. See also [MIT licence](https://opensource.org/license/mit).

- all \*.m files in directory: **/octave/struct**   
- all \*.m files in directory: **/octave/tex**   

The following files are licensed under the *Creative Commons Attribution 4.0 International* license. See also [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.en).

- all files in directory: **/octave/results** (including all sub-directories)   
- all files in directory: **/latex** (including all sub-directories)   
- the files *README.md* and *README.html*   


## Prerequisites

As a prerequisite, *GNU Octave 6.2.0* (or a more recent version) need to be installed. *GNU Octave* is available via the package management system on many Linux distributions. For *Microsoft Windows* or *MacOS* users it is suggested to download the *Windows* or *MacOS* version of *GNU Octave* and to install the software manually. See also: [GNU Octave download](https://octave.org/download)

To compile the MP4 video files (see *algo\_mp43.m*), the command line tool *ffmpeg* is required. In many Linux distributions, this tool can be installed using the package management system. For *Microsoft Windows* or *MacOS* users it is suggested to download the *Windows* or *MacOS* version of *ffmpeg* and to install the software manually. See also: [ffmpeg download](https://ffmpeg.org/download.html)


## Directory and file structure

All GNU Octave script files (\*.m) are written in the scientific programming language of *GNU Octave 6.2.0*. All Latex files (\*.tex) are written with compliance to *TeX-live* version 2020.20210202-3. Text files (\*.m, \*.tex) are generally encoded in UTF-8.

### Overview of the directory structure

```
signalmodelfitting-1.0.0   
├── latex   
│   ├── adaptthemePresRIP.tex   
│   ├── main.tex   
│   └── oct2texdefs.tex   
├── octave   
│   ├── aggregator   
│   ├── results   
│   ├── struct   
│   ├── tex   
│   ├── tools   
│   ├── algo_dsdefs.m   
│   ├── algo_mp43.m   
│   ├── algo_param.m   
│   ├── algo_sigfit.m   
│   ├── algo_sigmod.m   
│   └── init.m   
├── LICENSE   
├── README.html  
└── README.md   
```

### Brief description of files and folders

- **signalmodelfitting-1.0.0** ... main program directory
  - *LICENSE* ... text file, GNU Affero General Public License
  - *README.html* ... text file, HTML version of *README.md*
  - *README.md* ... text file, information about the program, this file
- **signalmodelfitting-1.0.0/latex** ... directory, LaTeX documents, presentation slides (CC BY 4.0)
  - *adaptthemePresRIP.tex* ... file, LaTeX beamer class configuration
  - *main.tex* ... file, main LaTeX document, presentation source code
  - *oct2texdefs.tex* ... file, conviniently import structure field values from GNU Octave data structures into LaTeX documents
- **signalmodelfitting-1.0.0/octave** ... directory, GNU Octave source code
  - *algo\_dsdefs.m* ... function file, data set definitions
  - *algo\_mp43.m* ... function file, create MP4 video file showing the semi-automated signal model fitting results
  - *algo\_param.m* ... function file, analysis parameter definitions
  - *algo\_sigfit.m* ... function file, visual signal inspection and semi-automated signal model fitting
  - *algo\_sigmod.m* ... function file, plot signal model
  - *init.m* ... function file, initialise program


## Installation instructions

### Data set installation

1. Download the data set records (see section **Related data sources**) from the repository and move them to a directory of your choice. e.g. **/home/acme/science/data/*\_dataset.tar.xz**
2. Extract data sets from the TAR archives using *GNU tar*. For *Microsoft Windows* users it is suggested to use *7-zip* instead.

```
bash: $ tar -xzf ts1_datasets.tar.xz
```

The expected outcome is to have all data sets (\*.oct files) in the directories of the respective test series.

```
home    
└── acme    
    └── science    
        └── data    
            ├── ts1_dataset    
            │   └── *.oct  
            ├── ts5_dataset    
            │   └── *.oct    
            ├── ts6_dataset    
            │   └── *.oct    
            └── ts7_dataset    
                └── *.oct    
```

> [!NOTE]
> *7-zip* is available online. [7-zip download](https://www.7-zip.org/download.html)


### Analysis script installation

1. Download the record containing the analysis code from the repository and move it to a directory of your choice. e.g. **/home/acme/science**   
2. Decompress analysis code from the ZIP archive **signalmodelfitting-1.0.0.zip**. e.g. **/home/acme/science/signalmodelfitting-1.0.0**   
3. Run GNU Octave.   
4. Make the program directory **/home/acme/science/paper2-analysis-1.0.0/octave** the working directory.   
5. Adjust the variables 'r\_ds.datapath' 'r\_ds.dspath1', 'r\_ds.dspath2', 'r\_ds.dspath3' and 'r\_ds.dspath4' in function file **/home/acme/science/signalmodelfitting-1.0.0/octave/algo\_param.m**. They have to point to the actual location of the folders containing the previously extracted data sets (\*.oct) of the respective test series.   

```
    algo_param.m:  ...    
    algo_param.m:  r_ds.datapath = fullfile(filesep(), 'home', 'acme', 'science', 'data'); # data set source path    
    algo_param.m:  r_ds.dspath1 = 'ts1_dataset'; # test series 1 data set directory    
    algo_param.m:  r_ds.dspath2 = 'ts5_dataset'; # test series 5 data set directory    
    algo_param.m:  r_ds.dspath3 = 'ts6_dataset'; # test series 6 data set directory    
    algo_param.m:  r_ds.dspath4 = 'ts7_dataset'; # test series 7 data set directory    
    algo_param.m:  ...    
```

## Usage instructions

1. Open GNU Octave.   
2. Initialise program.   
3. Run analysis.   


### Initialise program (command line interface)

The *init* function initialises the program. The initialisation must be run once before executing all the other functions. The command is adding the sub-directories included in the main program directory to the 'path' environment variable. This function also loads additional packages (e.g. the signal package).

```
    octave: >> init();   
```


### Run analysis (command line interface)

The *algo\_*.m* function files compile the analysis results and write them to the above-mentioned **/octave/results** directory. These functions are also plotting the analysis results. Since some of the algorithms depend on previously compiled analysis results, the order of executing the function files matters.

1. Manually pick the detection start point (selecting a sample index directly behind the sound wave's first local maximum's location)    
```  
    octave: >> algo_sigfit('pick', <DSTYPE>, <DSID>, <CID>);       
```
2. Automatically compile signal model fitting results    
```   
    octave: >> algo_sigfit('fit');     
```
3. Automatically plot signal model fitting results    
```    
    octave: >> algo_sigfit('plot');     
```
4. Automatically compile signal model fitting statistics    
``` 
    octave: >> algo_sigfit('stats');     
```
5. Automatically compile MP4 video files showing the semi-automated signal model fitting results    
```   
    octave: >> algo_mp43();      
```

**Note:**

- DSTYPE ... data set type identifier   
  - 1 = cement paste (test series 1)   
  - 2 = ambient air (test series 5)   
  - 3 = tap water (test series 6)   
  - 4 = aluminium cylinder (test series 7)   
- DSID ... dat set identifier   
  - integer number   
  - see also */octave/algo\_param.m* and */octave/algo\_dsdefs.m*)   
- CID ... channel identifier   
  - 1 = primary wave singal response (compression wave)   
  - 2 = secondary wave singal response (shear wave)   


## Help and Documentation

All function files contain an adequate function description and instructions on how to use the functions. The documentation can be displayed in the GNU Octave command line interface by entering the following command:

```
    octave: >> help function_file_name;    
```


## Related data sources

The data sets analysed in this publication are available at the repository of *Graz University of Technology* under the *Creative Commons Attribution 4.0 International* license. The data records enlisted below contain the raw data, the compiled data sets and a technical description of the record content. Additionally, a data descriptor (preprint) is available, which contains an elaborate descriptions of these data sets.


### Data records

- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 1, Cement Paste at Early Stages". Graz University of Technology. doi: [10.3217/bhs4g-m3z76](https://doi.org/10.3217/bhs4g-m3z76)   
- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 5, Reference Tests on Air". Graz University of Technology. doi: [10.3217/bjkrj-pg829](https://doi.org/10.3217/bjkrj-pg829)   
- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 6, Reference Tests on Water". Graz University of Technology. doi: [10.3217/hn7we-q7z09](https://doi.org/10.3217/hn7we-q7z09)   
- Harden, J. (2025) "Ultrasonic Pulse Transmission Tests: Datasets - Test Series 7, Reference Tests on Aluminium Cylinder (1.1)". Graz University of Technology. doi: [10.3217/w3mb5-1wx17](https://doi.org/10.3217/w3mb5-1wx17)   


### Data descriptor

- Harden, J. (2025). Experimental study on cement paste using the ultrasonic pulse transmission method (1.0.0). Graz University of Technology. doi: [10.31224/4465](https://doi.org/10.31224/4465), alternative doi: [10.20944/preprints202503.2008.v1](https://doi.org/10.20944/preprints202503.2008.v1)   
- Harden, J. (2025). Source code for: Experimental study on cement paste using the ultrasonic pulse transmission method (1.0.0-beta1). Graz University of Technology. doi: [10.3217/xmrmb-5ap42](https://doi.org/10.3217/xmrmb-5ap42)   

> [!NOTE]
> The source code for the data descriptor is also available on **GitHub**. [Source code](https://github.com/jakobharden/phd_paper_1_analysis)


## Related software

### Dataset Compiler, version 1.2:

The referenced data sets are compiled from raw data using a data set compilation tool implemented in the programming language of *GNU Octave 6.2.0*. To understand the structure of the data sets, it is a good idea to look at the source code of that tool. Therefore, it was made publicly available under the *MIT* license at the repository of *Graz University of Technology*.

- Harden, J. (2025) "Ultrasonic Pulse Transmission Tests: Data set compiler (1.2)". Graz University of Technology. doi: [10.3217/bcydt-6ta35](https://doi.org/10.3217/bcydt-6ta35)   

> [!NOTE]
> *Dataset Compiler* is also available on **GitHub**. [Dataset Compiler](https://github.com/jakobharden/phd_dataset_compiler)


### Dataset Exporter, version 1.1:

*Dataset Exporter* is implemented in the programming language of GNU Octave 6.2.0 and allows for exporting data contained in the data set. The main features of that script collection cover the export of substructures to variables and the serialisation to the CSV format, the JSON structure format and TeX code. It is also made publicly available under the *MIT* licence at the repository of *Graz University of Technology*.

- Harden, J. (2025) "Ultrasonic Pulse Transmission Tests: Dataset Exporter (1.1)". Graz University of Technology. doi: [10.3217/d3p6m-w7d64](https://doi.org/10.3217/d3p6m-w7d64)   

> [!NOTE]
> *Dataset Exporter* is also available on **GitHub**. [Dataset Exporter](https://github.com/jakobharden/phd_dataset_exporter)


### Dataset Viewer, version 1.0:

*Dataset Viewer* is implemented in the programming language of GNU Octave 6.2.0 and allows for plotting measurement data contained in the data set. The main features of that script collection cover 2D plots, 3D plots and rendering MP4 video files from the measurement data contained in the data set. It is also made publicly available under the *MIT* licence at the repository of *Graz University of Technology*.

- Harden, J. (2023) "Ultrasonic Pulse Transmission Tests: Dataset Viewer (1.0)". Graz University of Technology. doi: [10.3217/c1ccn-8m982](https://doi.org/10.3217/c1ccn-8m982)   

> [!NOTE]
> *Dataset Viewer* is also available on **GitHub**. [Dataset Viewer](https://github.com/jakobharden/phd_dataset_viewer)


## Revision and release history

Keywords:

- civil engineering
- signal analysis
- damped sinusoidal signal
- ultrasonic pulse transmission
- signal fitting
- signal model
- onset point
- time-of-flight
- time range


### 2025-09-19, Video files, version 1.0.0

- published/released by Jakob Harden   
- repository: YouTube   
- [Playlist 1](https://www.youtube.com/playlist?list=PLJZuQsRT0k-M7zaaBbiKMzlLKHiLl7K2j), UPTM - P-wave signal model fitting results, testing material: cement paste, ultrasonic measuring distance: 25, 50, 70 mm   
- [Playlist 2](https://www.youtube.com/playlist?list=PLJZuQsRT0k-PDwayMIp9qnjOUYo4H71Ea), UPTM - P-wave signal model fitting results, testing material: ambient air, ultrasonic measuring distance: 25, 50, 70, 90 mm   
- [Playlist 3](https://www.youtube.com/playlist?list=PLJZuQsRT0k-PcsCwiQu_qluBSBQJok2Zi), UPTM - P-wave signal model fitting results, testing material: tap water, ultrasonic measuring distance: 25, 50 mm   
- [Playlist 4](https://www.youtube.com/playlist?list=PLJZuQsRT0k-O9ZTgesZUKfYvqYNkToMEJ), UPTM - P-wave signal model fitting results, testing material: tap water, ultrasonic measuring distance: 70, 90 mm   
- [Playlist 5](https://www.youtube.com/playlist?list=PLJZuQsRT0k-NaoWA7EBHHLaojYXNR7s77), UPTM - P-wave signal model fitting results, testing material: aluminium cylinder, ultrasonic measuring distance: 50 mm   


### 2025-09-20, Presentation slide deck, version 1.0.0

- published/released by Jakob Harden   
- repository: [TU Graz Repository](http://doi.org/10.17616/R31NJMYL)   
- doi: [10.3217/8egy9-h8152](https://doi.org/10.3217/8egy9-h8152)   


### 2025-09-20, LaTeX code, version 1.0.0

- published/released by Jakob Harden   
- repository: [TU Graz Repository](http://doi.org/10.17616/R31NJMYL)   
- doi: [10.3217/pn7sy-hma06](https://doi.org/10.3217/pn7sy-hma06)   


### 2025-09-20, GNU Octave code to the presentation, version 1.0.0

- published/released by Jakob Harden   
- repository: [TU Graz Repository](http://doi.org/10.17616/R31NJMYL)   
- doi: [10.3217/x9htm-kxe18](https://doi.org/10.3217/x9htm-kxe18)   


### 2025-09-20, Video files to the presentation, version 1.0.0

- published/released by Jakob Harden   
- repository: [TU Graz Repository](http://doi.org/10.17616/R31NJMYL)   
- doi: [10.3217/5rgbw-a8v29](https://doi.org/10.3217/5rgbw-a8v29)   

