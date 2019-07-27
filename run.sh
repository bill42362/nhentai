#!/bin/bash
# Program:
#   This program fetch images from urls.

for url in $@; do
  sh getGalleryIdsFromUrl.sh "$url" | xargs sh getImagesByGalleryIds.sh
done
