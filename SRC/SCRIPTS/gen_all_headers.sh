#!/bin/bash

HEADER="$(dirname ${1})/all_headers.h"
echo "#ifndef __ALL_HEADERS__" > $HEADER
echo "#define __ALL_HEADERS__" >> $HEADER
for file in $(dirname ${1})/*.h
do
    test "$file" = ${HEADER} && continue
    echo "#include <$(basename $file)>" >> $HEADER
done
echo "#endif" >> $HEADER
