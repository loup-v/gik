#!/bin/sh




#
# COMMON FUNCTIONS
# >> START
#

# more powerful pattern matching
# https://stackoverflow.com/a/13509721
shopt -s extglob

echo_last_line()
{
  printf "\033[1A"
  printf "\033[K"
  echo $@
}

is_not_blank()
{
  # https://stackoverflow.com/a/13509721
  if [[ -n "${1##+([[:space:]])}" ]]; then
    return 0
  else
    return 1
  fi
}

is_blank()
{
  is_not_blank $1
  result=$?
  if [[ $result == 0 ]]; then
    return 1
  else
    return 0
  fi
}

is_prefixed_by()
{
  if [[ $1 == $2* ]]; then
    return 0
  else
    return 1
  fi
}

get_user_input()
{
  user_input_label=$1; shift

  user_input=""
  is_user_input_valid=1
  while [[ $is_user_input_valid != 0 ]]; do
    if [[ -z $user_input_label ]]; then
      read user_input
    else
      read -p "$user_input_label: " user_input
    fi

    is_user_input_valid=0

    user_input_function=
    user_input_error_message=
    for f in "$@"; do
      if [[ -z $user_input_function ]]; then
        user_input_function=$f
      else
        user_input_error_message=$f
      fi

      if ! [[ -z $user_input_function || -z $user_input_error_message ]]; then
        if ! $($user_input_function $user_input); then
          echo $user_input_error_message
          user_input=""
          is_user_input_valid=1
          break
        fi

        user_input_function=
        user_input_error_message=
      fi
    done
  done
}

get_user_input_or_default()
{
  default_input=$1; shift
  get_user_input "$@"

  if is_blank $user_input; then
    user_input=$default_input
  fi
}

function is_git_repository()
{
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    return 0
  else
    return 1
  fi
}


#
# COMMON FUNCTIONS
# << END
#


#
# PUSH
# << START
#

function perform_push()
{
  # abort if no skecth files found
  if [[ -z "$(ls | grep ".*\.sketch$")" ]]; then
    echo "no sketch files found"
    exit 1
  fi

  # init git repo if does not exist and push initial commit
  if ! is_git_repository; then
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
  fi

  # ask for git remote origin url if does not exist
  if [[ -z "$(git config remote.origin.url)" ]]; then

    function is_git_url() {
      if is_prefixed_by $1 "git@"; then
        return 0
      else
        return 1
      fi
    }

    get_user_input "enter the git remote origin url" is_not_blank "invalid url" is_git_url "invalid url, must start with git@..."
    git remote add origin $user_input 1>/dev/null || exit 1
  fi


  # try to connect to remote origin and get last commit
  echo "sync with remote origin: ..."

  if ! remote_last_commit=$(git ls-remote origin master 2>/dev/null); then
    echo_last_line "sync with remote origin: failed to connect"
    exit 1
  fi

  echo_last_line "sync with remote origin: ok"

  # push initial commit in case the remote origin is empty
  if [[ -z "$remote_last_commit" ]]; then
    echo "remote origin is empty, push initial commit"
    echo
    git push origin master || exit 1
    echo
  else
    # fetch remote origin and get last commits ref
    echo "fetch changes from remote origin"
    echo
    git fetch origin master >/dev/null || exit 1
    echo

    # [ $(git rev-parse HEAD) = $(git ls-remote origin master | cut -f1) ] && echo up to date || echo not up to date
    git_master_diff="$(git merge-base master origin/master)"

    if [[ -z $git_master_diff ]]; then
      echo "error: no common commit found"
      exit 1
    fi

    git_master_local="$(git rev-parse master)"
    git_master_remote="$(git rev-parse origin/master)"

    # in case remote is ahead of local, exit
    if [[ $git_master_local != $git_master_remote && $git_master_remote == $git_master_diff ]]; then
      upstream_commits_count="$(git rev-list HEAD...origin/master --count >/dev/null || "??")"
      echo "remote is ${upstream_commits_count} commit(s) ahead"
      echo "you need to pull and merge first (good luck)"
      exit 1
    fi
  fi


  for f in ./*.sketch
  do
    echo
    echo "extract $f"

    # extract filename
    # https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
    filename="${f##*/}"
    name="${filename%.*}"

    # copy .sketch to .zip
    cp $f $name.zip

    # before unzip, remove target in case it already exists
    rm -r $name &>/dev/null

    # unzip
    unzip -qq -o $name.zip -d $name/ &>/dev/null
    is_zip_success=$?
    rm $name.zip &>/dev/null

    if [[ $is_zip_success != 0 ]]; then
      echo "$f is not on Sketch 43 file system, ignoring"
      continue
    fi

    # remove preview files
    rm -r $name/previews/ &>/dev/null

    # stage files
    git add $name/
  done


  # check if there are other dirty files that are not sketch, abort if yes
  dirty_other_files="$(git status --porcelain | grep -v "^[A|M|D|R] \|.*\.sketch$" | cut -c 4-)"
  if ! [[ -z "$dirty_other_files" ]]; then
    echo
    echo "error: there are other (not .sketch) dirty files:"
    for f in $dirty_other_files; do
      echo "  * $f"
    done

    exit 1
  fi

  echo
  get_user_input_or_default "wip" "enter the commit message (or leave blank)"
  echo_last_line "enter the commit message (or leave blank): $user_input"
  echo

  git commit -m "$user_input" && git push origin master || exit 1


}


#
# PUSH
# << END
#


#
# PULL
# << START
#

function perform_pull()
{
  git pull origin master || exit 1
  echo

  for f in */; do
    target=${f%*/}.sketch
    echo "package $target"
    rm target &>/dev/null


    cd $f
    zip -qq -r $target .
    mv $target ..
    cd ..
  done
}


#
# PULL
# << END
#


#
# MAIN
# << START
#

# rm -rf .git

if ! type git &>/dev/null; then
  echo "git not installed"
  exit 1
fi

if [[ $1 != "push" && $1 != "pull" ]]; then
  echo "push or pull ?"
  exit 1
fi

if [[ $1 == "push" ]]; then
  perform_push
else
  perform_pull
fi

echo
echo "done!"
exit 0


#
# MAIN
# << END
#
