########################################
#### UNIVERSAL STATIC LIBRARY BUILD ####
########################################

# define output build folder
BUILD_FOLDER="build"

# define output folder environment variable
BUILD_DIR=${PWD}/${BUILD_FOLDER};

# define configuration type
CONFIGURATION="Release";

# define project name
PROJECT_NAME="push-sdk"

# define product prefix
PRODUCT_NAME="AeroGearPush"

# define the version of the final product
VERSION_NAME="1.1.1"

# define final product name
PRODUCT_LIBRARY_NAME="lib${PROJECT_NAME}-${VERSION_NAME}.a"

# define library path for the Simulator
SIMULATOR_LIBRARY_DIR="${BUILD_DIR}/${PRODUCT_NAME}-iphonesimulator"
SIMULATOR_HEADER_DIR="${SIMULATOR_LIBRARY_DIR}/include/${PROJECT_NAME}"
SIMULATOR_LIBRARY_PATH="${SIMULATOR_LIBRARY_DIR}/${PRODUCT_LIBRARY_NAME}"

# define library path for the Device
DEVICE_LIBRARY_DIR="${BUILD_DIR}/${PRODUCT_NAME}-iphoneos"
DEVICE_HEADER_DIR="${DEVICE_LIBRARY_DIR}/include/${PROJECT_NAME}"
DEVICE_LIBRARY_PATH="${DEVICE_LIBRARY_DIR}/${PRODUCT_LIBRARY_NAME}"

# define output and library path for the Universal Library
UNIVERSAL_LIBRARY_DIR="${BUILD_DIR}/${PRODUCT_NAME}-iphoneuniversal"
UNIVERSAL_HEADER_DIR="${UNIVERSAL_LIBRARY_DIR}/include/${PROJECT_NAME}"
UNIVERSAL_LIBRARY_PATH="${UNIVERSAL_LIBRARY_DIR}/${PRODUCT_LIBRARY_NAME}"

# define framework path
FRAMEWORK="${BUILD_DIR}/${PRODUCT_NAME}-framework/${PRODUCT_NAME}.framework"

# define product sources path
PRODUCT_SOURCES_PATH="${BUILD_DIR}/${PRODUCT_NAME}-sources-${VERSION_NAME}"

# cleaning output build folder
rm -Rf ${BUILD_DIR}

# creating output directories
mkdir -p ${SIMULATOR_HEADER_DIR}
mkdir -p ${DEVICE_HEADER_DIR}
mkdir -p ${UNIVERSAL_HEADER_DIR}
mkdir -p ${PRODUCT_SOURCES_PATH}

# Copying public header file
cp -v ./${PROJECT_NAME}/AeroGearPush.h ${SIMULATOR_HEADER_DIR}
cp -v ./${PROJECT_NAME}/AGClientDeviceInformation.h ${SIMULATOR_HEADER_DIR}
cp -v ./${PROJECT_NAME}/AGDeviceRegistration.h ${SIMULATOR_HEADER_DIR}
cp -v ./${PROJECT_NAME}/AGPushAnalytics.h ${SIMULATOR_HEADER_DIR}

cp -v ${SIMULATOR_HEADER_DIR}/*.h ${DEVICE_HEADER_DIR}


# Copying source files
cp -v  -R ./${PROJECT_NAME} ${PRODUCT_SOURCES_PATH}
cp -v ./LICENSE.txt ${PRODUCT_SOURCES_PATH}

echo '==== BUILDING Simulator Library of project: ' ${PROJECT_NAME} ' in path: ' ${SIMULATOR_LIBRARY_DIR} ' with configuration: ' ${CONFIGURATION};

# Step 1. Build Simulator library
xcodebuild -project ${PROJECT_NAME}.xcodeproj -sdk iphonesimulator -target ${PROJECT_NAME} -configuration ${CONFIGURATION} clean build TARGET_BUILD_DIR=${SIMULATOR_LIBRARY_DIR} PRODUCT_NAME=${PROJECT_NAME}-${VERSION_NAME}

echo '==== BUILDING Device Library of project: ' ${PROJECT_NAME} ' in path: ' ${DEVICE_LIBRARY_DIR} ' with configuration: ' ${CONFIGURATION};

# Step 2. Build Device library
xcodebuild -project ${PROJECT_NAME}.xcodeproj -sdk iphoneos -target ${PROJECT_NAME} -configuration ${CONFIGURATION} clean build VALID_ARCHS="armv7 armv7s arm64" ARCHS="armv7 armv7s arm64" TARGET_BUILD_DIR=${DEVICE_LIBRARY_DIR} PRODUCT_NAME=${PROJECT_NAME}-${VERSION_NAME}


echo '==== BUILDING Universal Library of project ' ${PROJECT_NAME} ' in path: ' ${UNIVERSAL_LIBRARY_DIR} ' with configuration: ' ${CONFIGURATION};

 
# Step 3. Create universal binary file using lipo

# Generate universal binary for the device and simulator.
lipo "${SIMULATOR_LIBRARY_PATH}" "${DEVICE_LIBRARY_PATH}" -create -output "${UNIVERSAL_LIBRARY_PATH}"

# Last touch. copy the header files.
cp -v ${DEVICE_HEADER_DIR}/*.h ${UNIVERSAL_HEADER_DIR}


#########################
#### FRAMEWORK BUILD ####
#########################


# Create framework directory structure.
mkdir -p "${FRAMEWORK}/Versions/${VERSION_NAME}/Headers" &&
mkdir -p "${FRAMEWORK}/Versions/${VERSION_NAME}/Resources"

 
# Move files to appropriate locations in framework paths.
cp "${UNIVERSAL_LIBRARY_PATH}" "${FRAMEWORK}/Versions/${VERSION_NAME}" &&
mv  "${FRAMEWORK}/Versions/${VERSION_NAME}/${PRODUCT_LIBRARY_NAME}" "${FRAMEWORK}/Versions/${VERSION_NAME}/${PRODUCT_NAME}" &&
ln -s "${VERSION_NAME}" "${FRAMEWORK}/Versions/Current" &&
ln -s "Versions/Current/Headers" "${FRAMEWORK}/Headers" &&
ln -s "Versions/Current/Resources" "${FRAMEWORK}/Resources" &&
ln -s "Versions/Current/${PRODUCT_NAME}" "${FRAMEWORK}/${PRODUCT_NAME}"

# Check the architectures included in the fat file (should be i386 armv6 armv7)
lipo -info "${FRAMEWORK}/${PRODUCT_NAME}"

# The -a ensures that the headers maintain the source modification date so that we don't constantly
# cause propagating rebuilds of files that import these headers.
cp -a ${UNIVERSAL_HEADER_DIR}/*.h ${FRAMEWORK}/Versions/${VERSION_NAME}/Headers

# replace placeholder in framework plist with framework name and copy to the bundle
cat "./${PROJECT_NAME}/push-sdk-fmwk-info.plist" | sed 's/${PRODUCT_NAME}/'"${PRODUCT_NAME}"'/' > ${FRAMEWORK}/Versions/${VERSION_NAME}/Resources/Info.plist


#########################################
#### ZIPPING LIBRARIES AND FRAMEWORK ####
#########################################

echo '==== Building zipped files of Libraries and Framework ===='

ditto -c -k --keepParent ${SIMULATOR_LIBRARY_DIR} ${BUILD_DIR}/${PRODUCT_NAME}-iphonesimulator-${VERSION_NAME}.zip
ditto -c -k --keepParent ${DEVICE_LIBRARY_DIR} ${BUILD_DIR}/${PRODUCT_NAME}-iphoneos-${VERSION_NAME}.zip
ditto -c -k --keepParent ${UNIVERSAL_LIBRARY_DIR} ${BUILD_DIR}/${PRODUCT_NAME}-iphoneuniversal-${VERSION_NAME}.zip
ditto -c -k --keepParent ${BUILD_DIR}/${PRODUCT_NAME}-framework ${BUILD_DIR}/${PRODUCT_NAME}-framework-${VERSION_NAME}.zip

##################################################
#### BUILDING .DMG OF LIBRARIES AND FRAMEWORK ####
##################################################

hdiutil create -volname ${PRODUCT_NAME}-iphonesimulator-${VERSION_NAME} -srcfolder ${SIMULATOR_LIBRARY_DIR} -ov -format UDZO ${BUILD_DIR}/${PRODUCT_NAME}-iphonesimulator-${VERSION_NAME}.dmg
hdiutil create -volname ${PRODUCT_NAME}-iphoneos-${VERSION_NAME} -srcfolder ${DEVICE_LIBRARY_DIR} -ov -format UDZO ${BUILD_DIR}/${PRODUCT_NAME}-iphoneos-${VERSION_NAME}.dmg
hdiutil create -volname ${PRODUCT_NAME}-iphoneuniversal-${VERSION_NAME} -srcfolder ${UNIVERSAL_LIBRARY_DIR} -ov -format UDZO ${BUILD_DIR}/${PRODUCT_NAME}-iphoneuniversal-${VERSION_NAME}.dmg
hdiutil create -volname ${PRODUCT_NAME}-framework-${VERSION_NAME} -srcfolder ${BUILD_DIR}/${PRODUCT_NAME}-framework -ov -format UDZO ${BUILD_DIR}/${PRODUCT_NAME}-framework-${VERSION_NAME}.dmg


#########################
#### ZIPPING SOURCES ####
#########################

echo '==== Building zipped files of sources ===='

ditto -c -k --keepParent ${PRODUCT_SOURCES_PATH} ${PRODUCT_SOURCES_PATH}.zip

##################################
#### BUILDING .DMG OF SOURCES ####
##################################

hdiutil create -volname ${PRODUCT_SOURCES_PATH} -srcfolder ${PRODUCT_SOURCES_PATH} -ov -format UDZO ${PRODUCT_SOURCES_PATH}.dmg



#######################
#### API DOC BUILD ####
#######################

APPLEDOC_FOLDER=./Docset

./appledoc.sh

##########################
#### ZIPPING API DOC  ####
##########################

echo '==== Building zipped files of API doc ===='

ditto -c -k --keepParent ${APPLEDOC_FOLDER} ${BUILD_DIR}/${PRODUCT_NAME}-docs-${VERSION_NAME}.zip


##################################
#### BUILDING .DMG OF API DOC ####
##################################

hdiutil create -volname ${PRODUCT_NAME}-docs-${VERSION_NAME} -srcfolder ${APPLEDOC_FOLDER} -ov -format UDZO ${BUILD_DIR}/${PRODUCT_NAME}-docs-${VERSION_NAME}.dmg

