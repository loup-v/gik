#!/bin/sh

if [[ $1 != "local" && $1 != "remote" ]]; then
  echo "test local or remote?"
  exit 1
fi

if [[ $2 == "reset" ]]; then
  rm -rf test &>/dev/null
fi

mkdir test &>/dev/null
cp test.sketch test
cd test

# copy git.sh from parent in order to match final commit content,
# but we don't use it
cp ../gik.sh .

if [[ $1 == "local" ]]; then
  cp ../../gik-base.sh .gik.sh
else
  curl https://raw.githubusercontent.com/loup-v/gik/master/gik.sh -o .gik.sh >/dev/null || exit 1
fi

chmod +x .gik.sh

if [[ ! -e ".git" ]]; then
  # force git init in the test folder,
  # otherwise the script will detect the parent git repo and try to use it

  # following code is copy pasted from git-base.sh

  echo "initialize git repository"
  git init >/dev/null || exit 1

  # stage script files
  git add gik.sh &>/dev/null

  # create .gitignore
  rm .gitignore &>/dev/null
  echo ".DS_Store" >> .gitignore
  echo "*.sketch" >> .gitignore
  echo ".gik.sh" >> .gitignore
  git add .gitignore

  echo "create initial commit"
  git commit -m "Initial commit." >/dev/null || exit 1

  # end copy paste

  if [[ $2 == "reset" ]]; then
    read -p "repo URL to reset: " repo_url
    git remote add origin $repo_url 1>/dev/null || exit 1
    echo "force push initial commit in order to reset remote origin"
    git push -f origin master || exit 1
    echo
  fi
fi

# shift reset
if [[ $2 == "reset" ]]; then
  shift
fi

# shift local|remote
shift

function cleanUp() {
  cd ..
  rm -rf test &>/dev/null
}
trap cleanUp EXIT

sh .gik.sh $@

exit 0
