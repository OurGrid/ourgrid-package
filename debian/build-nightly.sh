#!/bin/bash 
set -e

# Global nightly building script for OurGrid projects
# Iterates over all the project in the projects folder, 
# checks if there is new commit for it github that was not built yet
# and builds it. 

# Build variables
DEBFULLNAME="Abmar Barros (OurGrid Packaging)"
DEBEMAIL="abmar@lsd.ufcg.edu.br"

DIR_NAME="$(dirname $0)"
CURRENT_DIR="$(cd $DIR_NAME; pwd)"
PROJECTS_DIR=$CURRENT_DIR/projects
BUILD_DIR=$CURRENT_DIR/build

DATE=$(date +%Y%m%d)
DATE_REPR=$(date -R)

DOWNLOAD_ROOT=/tmp/build
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
  rsync -a $PROJECT_FOLDER/debian .

  cd $GIT_PATH
  CHANGELOG="$(git log $REV --pretty=format:'[ %an ]%n>%s' | $CURRENT_DIR/gitcl2deb.sh)"
  
  echo -e "${PACKAGE} (${DIST_REVISION}) ${DIST}; urgency=low\n\n\
${CHANGELOG}\n\n\
 -- ${DEBFULLNAME} <${DEBEMAIL}>  ${DATE_REPR}\n"\
  > $PROJECT_PATH/$SOURCE/debian/changelog

  cd $PROJECT_PATH/$SOURCE
  # Building debian package
  if [ "${BUILD_ARCH}" == "all" ]; then
    debuild
  else
    IFS=',' read -ra ARCHS <<< "${BUILD_ARCH}"
    for ARCH in "${ARCHS[@]}"; do
      debuild -a${ARCH} || true
    done
  fi 
    
  # Copy packages to download folder
  DOWNLOAD_PACKAGE_DIR=$DOWNLOAD_ROOT/$PACKAGE/$SOURCE
  mkdir -p $DOWNLOAD_PACKAGE_DIR
  rsync -a $PROJECT_PATH/${PACKAGE}_${BUILD_VERSION}* $DOWNLOAD_PACKAGE_DIR --exclude=*.build

done
