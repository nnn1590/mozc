# How to build Mozc in Docker

## Introduction
Docker containers are available to build Mozc binaries for Android JNI library and Linux desktop.

## System Requirements
Currently, only Ubuntu 20.04 is tested to host the Docker container to build Mozc.

## Set up Ubuntu 20.04 Docker container

```
curl -O https://raw.githubusercontent.com/nnn1590/mozc/nnn1590-newer-keepdroid/docker/ubuntu20.04/Dockerfile
sudo docker build --rm -t $USER/mozc_ubuntu20.04 .
sudo docker run --interactive --tty --rm $USER/mozc_ubuntu20.04
```

### Hint
Don't forget to rebuild Docker container when Dockerfile is updated.

-----

## Build Mozc for Linux Desktop

```
bazel build package --config oss_linux -c opt
```

`package` is an alias to build:
* //server:mozc_server
* //gui/tool:mozc_tool
* //renderer:mozc_renderer
* //unix/ibus:ibus_mozc
* //unix/icons
* //unix/emacs:mozc_emacs_helper

Unittests can be executed as follows.

```
bazel test base:util_test --config oss_linux -c dbg
```

## Build Mozc for Android:

```
python build_mozc.py gyp --target_platform=Android
python build_mozc.py build -c Debug android/android.gyp:apk
```

## Build Mozc library for Android:

See [upstream](https://github.com/google/mozc/blob/master/docs/build_mozc_in_docker.md#build-mozc-library-for-android).

-----

## Build Mozc for Linux Desktop with GYP (maintenance mode):

```
python3 build_mozc.py gyp
python3 build_mozc.py build -c Release package
```

`package` is an alias to build:
* //server:mozc_server
* //gui/tool:mozc_tool
* //renderer:mozc_renderer
* //unix/ibus:ibus_mozc


You can also run unittests as follows.

```
python3 build_mozc.py runtests -c Debug
```

### Differences between Bazel build and GYP build

GYP build is under maintenance mode. While the existing targets are supported
by both GYP and Bazel as much as possible, new targets will be supported by
Bazel only.

Targets only for Bazel:
* Zip code conversion (//server:mozc_server)
* Qt-based candidate window (//renderer:mozc_renderer)
* Build rules for icons (//unix/icons)


## GYP Build configurations
In `python3 build_mozc.py gyp` step, there are two different styles to customize configurations.  One is `GYP_DEFINES` environment variable and the other is commandline option.

```
[GYP_DEFINES="..."] python3 build_mozc.py gyp [options]
```

### GYP_DEFINES
You can specify `GYP_DEFINES` environment variable to change variables in GYP files, which you can find many directories in Mozc's source tree.  [common.gypi](../src/gyp/common.gypi) is an example.
Here are examples of GYP variables that you may want to change for Linux desktop build.

  * `document_dir`: Directory path where Mozc's license file is placed
  * `ibus_mozc_path`: ibus-mozc executable path
  * `ibus_mozc_icon_path`: ibus-mozc icon path

Note that you can specify multiple GYP variables as follows.

```
GYP_DEFINES="ibus_mozc_path=/usr/lib/ibus-mozc/ibus-engine-mozc ibus_mozc_icon_path=/usr/share/ibus-mozc/product_icon.png document_dir=/usr/share/doc/mozc" python3 build_mozc.py gyp
```

### command line options
You can find many command line options as follows.
```
python3 build_mozc.py gyp --help
```
Here we show some notable options.

#### --noqt
You can use `--noqt` option to build Mozc without depending on Qt 5 library.

#### --server_dir
You can use `--server_dir` option to specify the directory name where `mozc_server` will be installed.

### Compile options
In `build_mozc.py build` step, you can specify build types (`Release` or `Debug`) and one or more build targets.  Please find each GYP file to see what build targets are defined.

```
python3 build_mozc.py build -c {Release, Debug} [gyp_path_1.gyp:gyp_target_name1] [gyp_path_2.gyp:gyp_target_name2]
```
