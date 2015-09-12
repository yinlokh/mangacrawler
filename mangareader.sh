#! /bin/bash

currentPage="/"
currentPage+=$1
folderName=$2
domainName="http://www.mangareader.net"

while [ ${#currentPage} -gt 0 ]

do
  attempt=1
  url=$domainName
  url+=$currentPage

  while [ ! -e "page.html" ]

  do
    echo "ATTEMPT #" $attempt " FETCH " $url
    curl --retry 10 --retry-delay 1 $url -o page.html
    let "attempt += 1"
  done

  img=$(grep -oE "http://[A-Za-z0-9]*.readcdn.com/[A-Za-z0-9\/\-]*.jpg" page.html | head -n1)

  if [ ${#img} -eq 0 ]; then
    img=$(grep -oE "http://i[0-9]*.mangareader.net/[A-Za-z0-9\/\-]*.jpg" page.html | head -n1)
  fi

  nextUrl=$(grep -oE "next\"><a href=\"[A-Za-z0-9\/\-]*[.html]*" page.html | head -n1 | grep -o "/[A-Za-z0-9\/\-]*[.html]*")
  chapter=$(grep -oE "Chapter [0-9]+<\/h2" page.html | grep -oE "[0-9]+" | head -n1)
  page=$(grep -oE "Page [0-9]+<" page.html | grep -oE "[0-9]+")
  echo "DOWNLOADED HTML FOR " $chapter "/" $page " (url=" $img ")"

  filename=$folderName
  filename+="/"
  filename+=$chapter
  filename+="_-_"
  filename+=$page
  filename+=".jpg"

  echo "DOWNLOADING " $img " ==> " $filename

  curl $img -o $filename
  currentPage=$nextUrl
  rm page.html
done
