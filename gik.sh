#!/bin/sh

echo "fetch gik"
curl https://raw.githubusercontent.com/loup-studio/Gik/master/gik.sh -o gik.sh >/dev/null || exit 1
chmod +x .gik.sh

sh ./.gik.sh $@
rm .gik.sh
