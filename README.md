# gdc_download_tools
Directions and code for generic GDC data downloads.

# Background
The Cancer Genome Atlas and CCLE databases are now hosted on the Genomics Data Commons (GDC) and GDC Legacy Archive. Data files are no longer downloaded through interactive GUI but instead via remote connection.

The process to download is simple, but not too intuitive (hence this package). To designate files to download, it is necessary to generate a manifest using the main GDC site and clicking "download manifest". This file should then be used in the GDC download client as described below.

# Basic Steps

1. Download the manifest. Navigate to the main GDC page and subset the files of interest. Once this is completed, download the manifest. You can then place this in the same folder as the download assistant software.

2. Download the GDC client from the main GDC page. Unzip the software to the same directory as the manifest.

3. Use Command Prompt (Windows) or other command line program (Terminal in Mac, etc.) with the following commands: 

```
gdc-client download -m manifest.txt 
```
Where manifest.txt is replaced with the full filename+extension of your own manifest. 

Files will download to your current working directory. It works well to navigate to the same directory as the software and manifest, and to initiate the download from there.

# Example

To download the idat (level 1) HM450 methylation array images for COAD-READ cohort samples, first assemble a file manifest to be used in the GDAC download client.

First, navigate to the [TCGA Legacy Archive](https://portal.gdc.cancer.gov/legacy-archive/search/f). Toggle between the Cases and Files filter tabs to select filter criteria. Be sure specify the following:

1. Primary Site: "Colorectal"
2. Data Category: "Raw microarray data"
3. Experimental Strategy: "Methylation array"
4. Data Format: "idat" 
5. Platform: "Illumina Human Methylation 450"

Once these are specified, 918 files should be selected corresponding to the Red and Green channel idat files for available COAD and READ cohort samples. Click "Download Manifest".

Place the manifest in the same directory as the gdc client. From Windows Commander or equivalent prompt, navigate to the folder with the manifest and gdc download client. Enter the command above, specifying the name and extension of the manifest file just downloaded. This should create a new directory tree to which the files are downloaded.

#
