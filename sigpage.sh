# This script splits a pdf into pages and then replaces the last paged with a scanned page

# Usage: sigpage.sh <pdf file> <scanned page> <output file>
# Example: sigpage.sh mypdf.pdf myscannedpage.pdf myoutput.pdf

# Read in the arguments
pdf=$1
scanned=$2
output=$3

# Split the pdf into pages
pdfseparate $pdf page-%d.pdf

# Get the number of pages
num=$(pdfinfo $pdf | grep Pages | awk '{print $2}')

# Remove the last page
rm page-$num.pdf

# Copy the scanned page into this directory
cp "$scanned" lastpage.pdf

# Unite the pages into a new pdf
pdfunite page-*.pdf lastpage.pdf $output

# Clean up
rm page-*.pdf
rm lastpage.pdf