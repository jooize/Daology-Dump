#!/bin/sh

curl -o articles.html https://daology.org/articles
grep card_link articles.html | sed -E 's:.*href="([^"]+)".*>(.+)</a></h3>:\1 \2:' > articles

mkdir articles-raw
cat articles | sed -E 's:([^ ]*).*:https\://daology.org\1:' | while read link ; do
    filename=$(echo $link | sed -E 's:^.*/([^/]*)$:\1:')
    curl -o articles-raw/$filename $link/raw
done

mkdir articles-html
cd articles-html
cat ../articles | sed -E 's:([^ ]*).*:https\://daology.org\1:' | xargs -n 1 curl -O
cd ..

curl -o proposals.html https://daology.org/proposals
grep card_link proposals.html | sed -E 's:.*href="([^"]+)".*>(.+)</a></h3>:\1 \2:' > proposals

mkdir proposals-raw
cat proposals | sed -E 's:([^ ]*).*:https\://daology.org\1:' | while read link ; do
    filename=$(echo $link | sed -E 's:^.*/([^/]*)$:\1:')
    curl -o proposals-raw/$filename $link/raw
done

mkdir proposals-html
cd proposals-html
cat ../proposals | sed -E 's:([^ ]*).*:https\://daology.org\1:' | xargs -n 1 curl -O
cd ..

for raw in proposals-raw/* ; do
    filename=$(echo $raw | sed -E 's:.*/(.*):\1:')
    hash=$(grep 'meta_text hash' proposals-html/$filename | sed -E 's:.*>([A-Za-z0-9]+).*:\1:')
    if test $hash = 'DRAFT' ; then
        echo $filename DRAFT
    else
        filehash=$(cat $raw | openssl rmd160)
        if test $filehash = $hash ; then
            echo $filename OK
            echo $filehash = $hash
        else
            echo $filename FAIL
            echo $filehash != $hash
        fi
    fi
done
