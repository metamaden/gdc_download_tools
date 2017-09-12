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

