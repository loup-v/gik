#!/bin/sh

if [[ $1 != "local" && $1 != "remote" ]]; then
  echo "test local or remote ?"
  exit 1
fi

rm -r test &>/dev/null
mkdir test

cp test.sketch test
cd test

if [[ $1 == "local" ]]; then
  cp ../../gik-base.sh .gik.sh
else
  curl https://raw.githubusercontent.com/loup-studio/Gik/master/gik.sh -o .gik.sh >/dev/null || exit 1
fi

# force git init in the test folder,
# otherwise the script will detect the parent git repo and try to use it
git init >/dev/null || exit 1

chmod +x .gik.sh

shift
sh .gik.sh $@

cd ..
rm -r test &>/dev/null
