#!/bin/sh

echo "fetching script"
curl https://raw.githubusercontent.com/loup-studio/Gik/master/gik.sh -o .gik.sh >/dev/null || exit 1
chmod +x .gik.sh

function clean() {
  rm .gik.sh &>/dev/null
}
trap clean EXIT

sh .gik.sh $@
