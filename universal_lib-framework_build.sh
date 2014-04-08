########################################
#### UNIVERSAL STATIC LIBRARY BUILD ####
########################################


# define output folder environment variable
BUILD_DIR=${PWD};

# define configuration type
CONFIGURATION="Release";

# define project name
PROJECT_NAME="push-sdk"

# define the version of the final product
VERSION_NAME="0.9.0"

# define final product name
PRODUCT_NAME="lib${PROJECT_NAME}-${VERSION_NAME}.a"

# define library path for the Simulator
SIMULATOR_HEADER_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/include/${PROJECT_NAME}"
SIMULATOR_LIBRARY_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator"
SIMULATOR_LIBRARY_PATH="${SIMULATOR_LIBRARY_DIR}/${PRODUCT_NAME}"

# define library path for the Device
DEVICE_HEADER_DIR="${BUILD_DIR}/${CONFIGURATION}-iphoneos/include/${PROJECT_NAME}"
DEVICE_LIBRARY_DIR="${BUILD_DIR}/${CONFIGURATION}-iphoneos"
DEVICE_LIBRARY_PATH="${DEVICE_LIBRARY_DIR}/${PRODUCT_NAME}"

# define output and library path for the Universal Library
UNIVERSAL_HEADER_DIR="${BUILD_DIR}/${CONFIGURATION}-iphoneuniversal/include/${PROJECT_NAME}"
UNIVERSAL_LIBRARY_DIR="${BUILD_DIR}/${CONFIGURATION}-iphoneuniversal"
UNIVERSAL_LIBRARY_PATH="${UNIVERSAL_LIBRARY_DIR}/${PRODUCT_NAME}"

# define framework path
FRAMEWORK="${UNIVERSAL_LIBRARY_DIR}/${PRODUCT_NAME}.framework"

# cleaning output directories
rm -Rf "${SIMULATOR_LIBRARY_DIR}"
rm -Rf "${DEVICE_LIBRARY_DIR}"
rm -Rf "${UNIVERSAL_LIBRARY_DIR}"

# creating output directories
mkdir -p "${SIMULATOR_HEADER_DIR}"
mkdir -p "${DEVICE_HEADER_DIR}"
mkdir -p "${UNIVERSAL_HEADER_DIR}"

# Copying public header file
cp -v ${BUILD_DIR}/${PROJECT_NAME}/AeroGearPush.h ${SIMULATOR_HEADER_DIR}
cp -v ${BUILD_DIR}/${PROJECT_NAME}/AeroGearPush.h ${DEVICE_HEADER_DIR}


echo '==== BUILDING Simulator Library of project: ' ${PROJECT_NAME} ' in path: ' ${SIMULATOR_LIBRARY_DIR} ' with configuration: ' ${CONFIGURATION};

# Step 1. Build Simulator library
xcodebuild -project ${PROJECT_NAME}.xcodeproj -sdk iphonesimulator -target ${PROJECT_NAME} -configuration ${CONFIGURATION} clean build TARGET_BUILD_DIR=${SIMULATOR_LIBRARY_DIR}

echo '==== BUILDING Device Library of project: ' ${PROJECT_NAME} ' in path: ' ${DEVICE_LIBRARY_DIR} ' with configuration: ' ${CONFIGURATION};

# Step 2. Build Device library
xcodebuild -project ${PROJECT_NAME}.xcodeproj -sdk iphoneos -target ${PROJECT_NAME} -configuration ${CONFIGURATION} clean build TARGET_BUILD_DIR=${DEVICE_LIBRARY_DIR}

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
rm -rf "${FRAMEWORK}" &&
mkdir -p "${UNIVERSAL_LIBRARY_DIR}" &&
mkdir -p "${FRAMEWORK}/Versions/A/Headers" &&
mkdir -p "${FRAMEWORK}/Versions/A/Resources" &&

 
# Move files to appropriate locations in framework paths.
cp "${UNIVERSAL_LIBRARY_PATH}" "${FRAMEWORK}/Versions/A" &&
ln -s "A" "${FRAMEWORK}/Versions/Current" &&
ln -s "Versions/Current/Headers" "${FRAMEWORK}/Headers" &&
ln -s "Versions/Current/Resources" "${FRAMEWORK}/Resources" &&
ln -s "Versions/Current/${PRODUCT_NAME}" "${FRAMEWORK}/${PRODUCT_NAME}"

# Check the architectures included in the fat file (should be i386 armv6 armv7)
lipo -info "${FRAMEWORK}/${PRODUCT_NAME}"

# The -a ensures that the headers maintain the source modification date so that we don't constantly
# cause propagating rebuilds of files that import these headers.
cp -a ${UNIVERSAL_HEADER_DIR}/*.h ${FRAMEWORK}/Versions/A/Headers





