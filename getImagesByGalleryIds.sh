#!/bin/bash
# Program:
#   This program fetch images by gallery ids.

extsFilename=fileExts.txt
urlsFilename=fileUrls.txt

dist=dist
if [ ! -d "$dist" ]; then
  mkdir "$dist"
fi
cd "$dist"

for id in $@; do
  echo Parsing volume $id ...
  volUrl=https://nhentai.net/g/$id/
  volHtml=$(curl -s $volUrl)
  trimedHtml=$(echo $volHtml | head -n 1)

  title=$(echo $trimedHtml | sed 's/^.*<h1>//g' | sed 's/<\/h1>.*$//g' | tr '\/' '_')
  echo title: $title
  subTitle=$(echo $trimedHtml | sed 's/<\/h2>.*$//g' | sed 's/^.*<h2>//g' | tr '\/' '_')
  echo subTitle: $subTitle
  if [ "More Like This" != "$subTitle" ]; then
    mkdir "$subTitle"
    cd "$subTitle"
  else
    mkdir "$title"
    cd "$title"
  fi

  # https://t.nhentai.net/galleries/1200815/1t.jpg
  galleryId=$(echo $trimedHtml | sed 's/\/1t\..*$//g' | sed 's/^.*galleries\///g')
  echo galleryId: $galleryId
  pageCount=$(echo $trimedHtml | sed 's/pages.*$//g' | sed 's/^.*div>//g' | tr -d '[:space:]')
  echo pageCount: $pageCount
  ## https://t.nhentai.net/galleries/1442208/29t.png
  for imageIndex in $(seq 1 $pageCount); do
    # https://i.nhentai.net/galleries/1200815/3.jpg
    imageExt=$(echo $trimedHtml | sed 's/^.*'"$galleryId"'\/'"$imageIndex"'t\.//g' | sed 's/".*$//g')
    fileUrl=https://i.nhentai.net/galleries/$galleryId/$imageIndex.$imageExt
    echo "$fileUrl" >> "$urlsFilename"
    echo "$imageExt" >> "$extsFilename"
  done

  exts=$(sort "$extsFilename")
  firstExt=$(echo "$exts" | head -n1)
  lastExt=$(echo "$exts" | tail -n1)
  if [ "$firstExt" == "$lastExt" ]; then
    #$mUrl=https://i.nhentai.net/galleries/$galleryId/[1-$pageCount].$firstExt
    #echo "$mUrl"
    curl -O -J "https://i.nhentai.net/galleries/$galleryId/[1-$pageCount].$firstExt"
  else
    xargs -n 1 curl -O -J < "$urlsFilename"
  fi

  rm "$urlsFilename"
  rm "$extsFilename"

  cd ..
done

cd ..
