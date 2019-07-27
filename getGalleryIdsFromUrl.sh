#!/bin/bash
# Program:
#   This program fetch gallery id from provided url.

tempHtml="temp.html"
curl -s $1 -o "$tempHtml"

# <a href="?page=1" class="page current">1</a>
pageSearches=$(grep '^.*<a .*class="page.*<\/a>' "$tempHtml" | sed 's/^.*href="//g' | sed 's/".*$//g')
if [ "" == "$pageSearches" ]; then
  pageSearches="?"
fi

rm "$tempHtml"

galleryIds=""
for pageSearch in $pageSearches; do
  page=$(echo $pageSearch | sed 's/^.*=//')
  curl -s "$1$pageSearch" -o "$page.html"

  # <div class="gallery" data-tags="6346 7752 8378 9162 13140 13515 14283 17349 21712 23895 27384 29013 29859 30082 32341 33172 107705"><a href="/g/279211/" class="cover" style="padding:0 0 141.2% 0"><img is="lazyload-image" class="lazyload " width="250" height="353" data-src="https://t.nhentai.net/galleries/1436824/thumb.jpg" alt="" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" /><noscript><img src="https://t.nhentai.net/galleries/1436824/thumb.jpg" width="250" height="353" alt="" /></noscript><div class="caption">[Shounen Zoom (Juumaru Shigeru)] Manga Shounen Zoom Vol. 32 [Digital]</div></a></div>
  galleryIds="$galleryIds $(grep 'galleries.*thumb' "$page.html" | sed 's/^.*\/g\///g' | sed 's/\/.*$//g')"

  rm "$page.html"
done

echo "$galleryIds"
