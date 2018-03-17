# Git Sketch version control

Works with Sketch new file format, introduced in Sketch version 43.

Rather than pushing .sketch binaries to Git, Gik allows to automatically track JSON files that lies underneath.

 * Unpack and commit JSON files when pushing
 * Repack to .sketch when pulling


## Advantages

 * Smaller git history size
 * Ground for visual diff between commits


## Installation

Copy the file `gik.sh` to your repository that contain the Sketch files to track.  
This file acts like a proxy to the real `gik-base.sh` and allows seamless updates of the script when necessary.

You can download `gik.sh` using the following one liner.  
Open your terminal, go to the project directory and run:

```
curl https://raw.githubusercontent.com/loup-v/gik/master/gik.sh -o gik.sh && chmod +x gik.sh
```

## Usage

### Push

```
./gik.sh push
```

If the git repository does not exist, the script will do it for you and ask for the remote origin url.

### Pull

```
./gik.sh pull
```


## Test

See `test/test.sh`, with the following usage:

```
./test.sh [local|remote] [reset|] [push|pull]
```

 * `local|remote`: use `git-base.sh` from the current project or from latest github release
 * `reset`: optional, reset the remote origin branch before running the real script
 * `push|pull`: params for the real script

Example of a repository managed by Gik: <https://github.com/loup-v/gik-test>


## Limitations

 * Merge conflicts must be handled manually
