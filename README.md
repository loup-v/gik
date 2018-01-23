# Git Sketch version control

Works with Sketch new file format, introduced in Sketch version 43.

Rather than pushing .sketch binaries to Git, Gik allows to automatically track JSON files that lies underneath.

 * Unpack and commit JSON files when pushing
 * Repack to .sketch when pulling


## Advantages

 * Smaller git history size
 * Ground for visual diff between commits


## Usage

Copy the file `gik.sh` to your repository that contain the Sketch files to track.  
This file acts like a proxy to the real `gik-base.sh` and allows seamless updates of the script when necessary.

### Push

```
./gik.sh push
```

If the git repository does not exist, the script will do it for you and ask for the remote origin url.

### Pull

```
./gik.sh pull
```


## Limitations

 * Merge conflicts must be handled manually
