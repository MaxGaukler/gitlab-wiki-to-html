#!/bin/bash
set -e
scriptdir="$(dirname $(readlink -f $0))"
outputdir="$3"
test -n "$outputdir" && test -d "$outputdir" || { echo "usage: $0 https://some-gitlab/  user/project local-output-dir/ [_gitlab_session cookie hex value]"; exit 1; }
cd "$outputdir" 
mkdir -p html/

### 1. DOWNLOAD HTML FILES
cd html
wget --rejected-log=rejected-urls.log --header "Cookie: _gitlab_session=$4" -r -k -p "$1$2/wikis/" -I "/$2/uploads,/$2/wikis,/assets" -R '*?version_id=*,?view=create,edit,history,git_access'
for i in */assets/*.css; do cat "$scriptdir"/remove-dynamic-content.css >> $i; done
# TODO: strip trailing / from $2.
# fixup lazy-loaded images (src="data:image-gif..." class="lazy" data-src="/user/project/uploads/.../source.png' for uploads,   or data-src="./source.png" for images inside wiki-git)
find -type f \( -name '*.html' -o -name '*.1' -o -not -name '*.*' \) -exec sed 's/src="data:image\/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="//g;s| data-src="'/$2/'| src="../../|g;s| data-src="| src="|g' -i '{}' ';'

xdg-open */$2/wikis/index.html

### 2. PDF GENERATION
### 2.1 PREPROCESS HTML

cd ..
cp -r html temp-for-pdf
cd temp-for-pdf

# work around a few bugs where gitlab doesn't enforce canonic URLs:
# force ending as .html, force filename as lowercase (except files already ending in .html), "-" is equal to " "
find -type f \( -name '*.1' -o -not -name '*.*' \)  -execdir cp '{}'  '{}.copy.html' ';' -execdir rename -f 'y/A-Z\-/a-z /' '{}.copy.html' ';'

# deduplication: x.1 == x/index.html
for dir in $(find -mindepth 1 -type d); do
    dirname="$(basename $dir)"
    dirname="${dirname,,}" # convert to lowercase
    test -f $dir/index.html && rm -f $dir/../${dirname}.1.copy.html
done

### 2.2 GENERATE PDF
find -name '*.html' -print -execdir chromium --headless --disable-gpu --print-to-pdf '{}' ';'  -execdir mv 'output.pdf' '{}.pdf' ';'
find -name '*.pdf' -exec pdfjoin --outfile all.pdf '{}' +
mv all.pdf ../
cd ..

xdg-open all.pdf
