# gdc_download_tools
Directions and code for generic GDC data downloads.

# Background
The Cancer Genome Atlas (TCGA) and CCLE databases are now hosted on the [Genomics Data Commons (GDC)](https://portal.gdc.cancer.gov/projects) and [TCGA Legacy Archive](https://portal.gdc.cancer.gov/legacy-archive/search/f). Large batches of data files are now best downloaded via remote connection using a manifest and the GDC download tool.

The process to download is simple, but not too intuitive (hence this package). To designate files to download, it is necessary to generate a manifest using the main GDC site and clicking "download manifest". This file should then be used in the GDC download client as described below.

# Basic Steps

1. Download the manifest. Navigate to the main GDC page and subset the files of interest. Once this is completed, download the manifest. You can then place this in the same folder as the download assistant software.

2. Download the GDC Data Transfer Tool client from the main GDC page [here](https://gdc.cancer.gov/access-data/gdc-data-transfer-tool). Unzip the software to the same directory as the manifest.

3. Use Command Prompt (Windows) or other command line program (Terminal in Mac, etc.) with the following commands: 

```
gdc-client download -m manifest.txt 
```
Where manifest.txt is replaced with the full filename+extension of your own manifest. 

Files will download to your current working directory. It works well to navigate to the same directory as the software and manifest, and to initiate the download from there.

# File Types
Available data is stored in a variety of different formats, each of which typically has its own semantics, standards, and QC. Check the semantics online, and also check the preprocessing pipeline(s) on the TCGA wiki page.

# XML Files
Often, clinical, biospecimen, and tumor data are available only in XML format. Thus it can be very useful to know how to parse these XML files and re-format as a flat dataframe. For more information and an implementation with the COAD-READ project files, see the 'gdc_xml_process' folder in the coad-read example files. See example below for instructions on working XML files from GDC.

# Example Remote GDC Batch File Download

To download the idat (level 1) HM450 methylation array images for COAD-READ cohort samples, first assemble a file manifest to be used in the GDC File Transfer client.

First, navigate to the [TCGA Legacy Archive](https://portal.gdc.cancer.gov/legacy-archive/search/f). Toggle between the Cases and Files filter tabs to select filter criteria. Be sure specify the following:

1. Primary Site: "Colorectal"
2. Data Category: "Raw microarray data"
3. Experimental Strategy: "Methylation array"
4. Data Format: "idat" 
5. Platform: "Illumina Human Methylation 450"

Once these are specified, 918 files should be selected corresponding to the Red and Green channel idat files for available COAD and READ cohort samples. Click "Download Manifest".

Place the manifest in the same directory as the gdc client. From Windows Commander or equivalent prompt, navigate to the folder with the manifest and gdc download client. Use the appropriate code in Terminal, Commander, etc. For example, the manifest "gdc_manifest.2017-10-26T17-53-35.235004.txt" (contained in the examples subdirectory of this module) contains information for downloading idat files for the COAD-READ TCGA cohorts, and the appropriate command line code would be:

```
gdc-client download -m gdc_manifest.2017-10-26T17-53-35.235004.txt 
```

This should create a new directory tree to which the files are downloaded. Supplementary files for this example are provided in the examples subdirectory.

# XML Files Example: COAD-READ Biospecimen Data
This example outlines a proof-of-principle for aggregating patient-level Biospecimen data, in XML format, into a flat dataframe with R. Files for this example can be found in the examples/coad-read/gdc_xml_process subdirectory. 

After you have downloaded the manifest for all COAD-READ biospecimen files and remotely downloaded these files locally with the gdc download client, you can iterate over the patient-level subdirectories as follows:
```
library(XML) # load the XML R module

# get a list of the names of directories with patient XML files
fn <- list.files()
fn.oi <- fn[nchar(fn)==36]; length(fn.oi) # 633 xml files for COAD-READ

# instantiate a new list to hold parsed XML data for patients
xmlcr.list <- list()

# loop over the subdirectories and parse XML files
for(i in 1:length(fn.oi)){
  x <- fn.oi[i]
  pathi <- paste0(getwd(),"/",x)
  lfi <- list.files(pathi); lfi.xml <- lfi[grepl(".xml",lfi)]
  pathi.xml <- paste0(pathi,"/",lfi[grepl(".xml",lfi)])
  xmli <- xmlToList(xmlParse(pathi.xml))
  
  slide.sidei <- xmli$patient$samples$sample$portions$portion$slides$slide$section_location$text
  
  xmlcr.list[length(xmlcr.list)+1] <- list(xmli$patient)
  names(xmlcr.list)[length(xmlcr.list)] <- paste0("patid-",xmli$patient$patient_id$text)
  message(i)
}

# resulting xmlcr.list should consist of a list of patient-level data (format is a tree of lists)
# with names(xmlcr.list) being the patient ID

head(names(xmlcr.list)) # returns:
# [1] "patid-3968" "patid-3530" "patid-A01I" "patid-6295" "patid-6809" "patid-3582"

names(xmlcr.list$`patid-3968`) # returns:
#[1] "additional_studies"  "bcr_patient_barcode" "bcr_patient_uuid"    "tissue_source_site"  "patient_id"         
#[6] "gender"              "days_to_index"       "bcr_canonical_check" "samples"

# to access slide-level biospecimen data for a patient, note the number of available slides first

length(xmlcr.list$`patid-3968`$samples$sample$portions$portion$slides)
# [1] 2

# NOTE: slide items will all be called 'slide', so R studio auto-complete will only show one slide name.
# By default, the first item named slide will display.
# Instead of calling '$slide', where there is >1 slide, use a position index such as '[[1]]' or '[[2]]'

xi <- xmlcr.list$`patid-3968`$samples$sample$portions$portion$slides

# get the barcodes for each slide for this patient
xi[[1]]$bcr_slide_barcode$text # returns:
#[1] "TCGA-AA-3968-01A-01-BS1" # 'B' -> "BOTTOM" slide
xi[[2]]$bcr_slide_barcode$text # returns: 
#[1] "TCGA-AA-3968-01A-01-TS1" # 'T' -> "TOP" slide

# view the biospecimen data for a slide
names(xi[[1]]) # returns:
# [1] "additional_studies"               "section_location"                 "number_proliferating_cells"      
# [4] "percent_tumor_cells"              "percent_tumor_nuclei"             "percent_normal_cells"            
# [7] "percent_necrosis"                 "percent_stromal_cells"            "percent_inflam_infiltration"     
#[10] "percent_lymphocyte_infiltration"  "percent_monocyte_infiltration"    "percent_granulocyte_infiltration"
#[13] "percent_neutrophil_infiltration"  "percent_eosinophil_infiltration"  "bcr_slide_barcode"               
#[16] "bcr_slide_uuid"                   "image_file_name"                  "is_derived_from_ffpe"

# access the percent tumor cells for the first slide
xi[[1]]$percent_tumor_cells$text # returns:
#[1] "95"

```
