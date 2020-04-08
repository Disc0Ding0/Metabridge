# Metabridge
A script that bridges the gap between metagoofil and exiftool to be used when searching the web for document metadata.

## Overview
This script is designed to help automate the harvesting of metadata from files hosted on a web server availble to google. It uses both metagoofil (to dork google finding files) and exiftool to scrape the metadata from the collected files. This is particularly useful when assessing brochureware during a penetration testing engagement.

## Requirements
This was written, designed for and tested on Kali Linux. For this script to work you must have both metagoofil and exiftool installed already. These can be installed as follows:
```sudo apt-get install metagoofil libimage-exiftool-perl```

## Usage
Metabridge creates a safe environment for working in with regards to metadata extraction. The basic usage is as follows:
```./metabridge.sh```
This will display a menu to the user which can be utilised by selecting the required options number. From there details can be entered with the results seen in the 'results.txt' file.


