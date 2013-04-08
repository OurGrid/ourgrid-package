#!/bin/bash 
set -e

DIR_NAME="$(dirname $0)"
CURRENT_DIR="$(cd $DIR_NAME; pwd)"
PROJECTS_DIR=$CURRENT_DIR/projects
BUILD_DIR=$CURRENT_DIR/build

DATE=$(date +%Y%m%d)
DATE_REPR=$(date -R)

GIT_URL=https://github.com/OurGrid/OurGrid.git
GIT_PATH=$BUILD_DIR/git

# Updating git folder
if [ -d "$GIT_PATH" ]; then
  cd $GIT_PATH
  git pull
  cd $CURRENT_DIR
else
  git clone $GIT_URL $GIT_PATH
fi

cd $GIT_PATH
REV="$(git log -1 --pretty=format:%h)"

if [ -f $BUILD_DIR/prev.rev ]; then
  REV_PREV="$(cat $BUILD_DIR/prev.rev)"
fi

if [ "$REV" == "$REV_PREV" ]; then
  echo "No need to build!"
  exit 0
fi

# Save previous build info
echo "$REV" > $BUILD_DIR/prev.rev

for PROJECT_FOLDER in $PROJECTS_DIR/*; do
  
  echo "Processing project $PROJECT_FOLDER"
  source $PROJECT_FOLDER/configure
  
  # Setting project properties
  PROJECT_PATH=$BUILD_DIR/$PROJECT_NAME
  mkdir -p $PROJECT_PATH
  
  BUILD_VERSION="${DIST_VERSION}+dev${DATE}.git.${REV}"
  DIST_REVISION="${BUILD_VERSION}-1"
  
  SOURCE="${PACKAGE}-${BUILD_VERSION}"
  ORIG_TGZ="${PACKAGE}_${BUILD_VERSION}.orig.tar.gz"
  
  echo "Building orig.tar.gz ..."
  cd $GIT_PATH
  git archive --format=tar "--prefix=${SOURCE}/" "${REV}" | gzip >"${PROJECT_PATH}/${ORIG_TGZ}"

  cd $PROJECT_PATH
  tar xzf $ORIG_TGZ

  cd $PROJECT_PATH/$SOURCE
  cp -r $PROJECT_FOLDER/inno .  
  cp -r $CURRENT_DIR/common/* ./inno
  bash ./inno/pre-build.sh
  iscc inno/build.iss
    
  # Copy packages to download folder
  # DOWNLOAD_PACKAGE_DIR=$DOWNLOAD_ROOT/$PACKAGE/$SOURCE
  # mkdir -p $DOWNLOAD_PACKAGE_DIR
  # rsync -a $PROJECT_PATH/${PACKAGE}_${BUILD_VERSION}* $DOWNLOAD_PACKAGE_DIR --exclude=*.build

done