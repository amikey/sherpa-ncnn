#!/usr/bin/env bash

# Please set the environment variable ANDROID_NDK
# before running this script

# Inside the $ANDROID_NDK directory, you can find a binary ndk-build
# and some other files like the file "build/cmake/android.toolchain.cmake"

set -e

log() {
  # This function is from espnet
  local fname=${BASH_SOURCE[1]##*/}
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}

SHERPA_NCNN_VERSION=$(grep "SHERPA_NCNN_VERSION" ./CMakeLists.txt  | cut -d " " -f 2  | cut -d '"' -f 2)

log "Building APK for sherpa-ncnn v${SHERPA_NCNN_VERSION}"

log "====================arm64-v8a================="
./build-android-arm64-v8a.sh
log "====================armv7-eabi================"
./build-android-armv7-eabi.sh
log "====================x86-64===================="
./build-android-x86-64.sh
log "====================x86===================="
./build-android-x86.sh


mkdir -p apks

# type 2
log "https://huggingface.co/csukuangfj/sherpa-ncnn-streaming-zipformer-bilingual-zh-en-2023-02-13"

# Download the model
# see https://k2-fsa.github.io/sherpa/ncnn/pretrained_models/zipformer-transucer-models.html#csukuangfj-sherpa-ncnn-streaming-zipformer-bilingual-zh-en-2023-02-13-bilingual-chinese-english
repo_url=https://huggingface.co/csukuangfj/sherpa-ncnn-streaming-zipformer-bilingual-zh-en-2023-02-13
log "Start testing ${repo_url}"
repo=$(basename $repo_url)
log "Download pretrained model and test-data from $repo_url"
GIT_LFS_SKIP_SMUDGE=1 git clone $repo_url
pushd $repo
git lfs pull --include "*.bin"

# remove .git to save spaces
rm -rf .git
rm .gitattributes
rm -rfv test_wavs
rm -v export-for-ncnn-bilingual.sh
rm README.md
ls -lh
popd

mv -v $repo ./android/SherpaNcnn/app/src/main/assets/
tree ./android/SherpaNcnn/app/src/main/assets/

pushd android/SherpaNcnn/app/src/main/java/com/k2fsa/sherpa/ncnn
sed -i.bak s/"type = 1"/"type = 2"/ ./MainActivity.kt
git diff
popd

for arch in arm64-v8a armeabi-v7a x86_64 x86; do
  log "------------------------------------------------------------"
  log "build apk for $arch"
  log "------------------------------------------------------------"
  src_arch=$arch
  if [ $arch == "armeabi-v7a" ]; then
    src_arch=armv7-eabi
  elif [ $arch == "x86_64" ]; then
    src_arch=x86-64
  fi

  ls -lh ./build-android-$src_arch/install/lib/*.so

  cp -v ./build-android-$src_arch/install/lib/*.so ./android/SherpaNcnn/app/src/main/jniLibs/$arch/

  pushd ./android/SherpaNcnn
  ./gradlew build
  popd

  mv android/SherpaNcnn/app/build/outputs/apk/debug/app-debug.apk ./apks/sherpa-ncnn-${SHERPA_NCNN_VERSION}-cpu-$arch-bilingual-en-zh.apk
  ls -lh apks
  rm -v ./android/SherpaNcnn/app/src/main/jniLibs/$arch/*.so
done

git checkout .

rm -rf ./android/SherpaNcnn/app/src/main/assets/$repo

# type 3
log "https://huggingface.co/csukuangfj/sherpa-ncnn-streaming-zipformer-en-2023-02-13"

# Download the model
# see https://k2-fsa.github.io/sherpa/ncnn/pretrained_models/zipformer-transucer-models.html#csukuangfj-sherpa-ncnn-streaming-zipformer-en-2023-02-13-english
repo_url=https://huggingface.co/csukuangfj/sherpa-ncnn-streaming-zipformer-en-2023-02-13
log "Start testing ${repo_url}"
repo=$(basename $repo_url)
log "Download pretrained model and test-data from $repo_url"
GIT_LFS_SKIP_SMUDGE=1 git clone $repo_url
pushd $repo
git lfs pull --include "*.bin"

# remove .git to save spaces
rm -rf .git
rm .gitattributes
rm -rfv test_wavs
rm -v README.md
rm -v export*.sh
ls -lh
popd

mv -v $repo ./android/SherpaNcnn/app/src/main/assets/
tree ./android/SherpaNcnn/app/src/main/assets/

pushd android/SherpaNcnn/app/src/main/java/com/k2fsa/sherpa/ncnn
sed -i.bak s/"type = 1"/"type = 3"/ ./MainActivity.kt
git diff
popd

for arch in arm64-v8a armeabi-v7a x86_64 x86; do
  log "------------------------------------------------------------"
  log "build apk for $arch"
  log "------------------------------------------------------------"
  src_arch=$arch
  if [ $arch == "armeabi-v7a" ]; then
    src_arch=armv7-eabi
  elif [ $arch == "x86_64" ]; then
    src_arch=x86-64
  fi

  ls -lh ./build-android-$src_arch/install/lib/*.so

  cp -v ./build-android-$src_arch/install/lib/*.so ./android/SherpaNcnn/app/src/main/jniLibs/$arch/

  pushd ./android/SherpaNcnn
  ./gradlew build
  popd

  mv android/SherpaNcnn/app/build/outputs/apk/debug/app-debug.apk ./apks/sherpa-ncnn-${SHERPA_NCNN_VERSION}-cpu-$arch-en.apk
  ls -lh apks
  rm -v ./android/SherpaNcnn/app/src/main/jniLibs/$arch/*.so
done

git checkout .

rm -rf ./android/SherpaNcnn/app/src/main/assets/$repo

# type 4
log "https://huggingface.co/shaojieli/sherpa-ncnn-streaming-zipformer-fr-2023-04-14"

# Download the model
# see https://k2-fsa.github.io/sherpa/ncnn/pretrained_models/zipformer-transucer-models.html#shaojieli-sherpa-ncnn-streaming-zipformer-fr-2023-04-14
repo_url=https://huggingface.co/shaojieli/sherpa-ncnn-streaming-zipformer-fr-2023-04-14
log "Start testing ${repo_url}"
repo=$(basename $repo_url)
log "Download pretrained model and test-data from $repo_url"
GIT_LFS_SKIP_SMUDGE=1 git clone $repo_url
pushd $repo
git lfs pull --include "*.bin"

# remove .git to save spaces
rm -rf .git
rm .gitattributes
rm -rfv test_wavs
rm -v README.md
rm -v export*.sh
ls -lh
popd

mv -v $repo ./android/SherpaNcnn/app/src/main/assets/
tree ./android/SherpaNcnn/app/src/main/assets/

pushd android/SherpaNcnn/app/src/main/java/com/k2fsa/sherpa/ncnn
sed -i.bak s/"type = 1"/"type = 4"/ ./MainActivity.kt
git diff
popd

for arch in arm64-v8a armeabi-v7a x86_64 x86; do
  log "------------------------------------------------------------"
  log "build apk for $arch"
  log "------------------------------------------------------------"
  src_arch=$arch
  if [ $arch == "armeabi-v7a" ]; then
    src_arch=armv7-eabi
  elif [ $arch == "x86_64" ]; then
    src_arch=x86-64
  fi

  ls -lh ./build-android-$src_arch/install/lib/*.so

  cp -v ./build-android-$src_arch/install/lib/*.so ./android/SherpaNcnn/app/src/main/jniLibs/$arch/

  pushd ./android/SherpaNcnn
  ./gradlew build
  popd

  mv android/SherpaNcnn/app/build/outputs/apk/debug/app-debug.apk ./apks/sherpa-ncnn-${SHERPA_NCNN_VERSION}-cpu-$arch-fr.apk
  ls -lh apks
  rm -v ./android/SherpaNcnn/app/src/main/jniLibs/$arch/*.so
done

git checkout .

rm -rf ./android/SherpaNcnn/app/src/main/assets/$repo

ls -lh apks/
