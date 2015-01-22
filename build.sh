########################################
#   UNIVERSAL FRAMEWORK LIBRARY BUILD  #
########################################

# define output build folder
BUILD_FOLDER="build"

# define configuration type
CONFIGURATION="Release";

# define output folder environment variable
BUILD_DIR=${PWD}/${BUILD_FOLDER};
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

# define project name
PROJECT_NAME="AeroGearPush"

# define framework path
FRAMEWORK="${BUILD_DIR}/${PRODUCT_NAME}-framework/${PRODUCT_NAME}.framework"

# cleaning output build folder
rm -Rf ${BUILD_DIR}

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"
 
# Step 1. Build Device and Simulator versions
xcodebuild -target "${PROJECT_NAME}" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build
xcodebuild -target "${PROJECT_NAME}" -configuration ${CONFIGURATION} -sdk iphonesimulator BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build
 
# Step 2. Copy the framework structure to the universal folder, plus merge their 'Modules' directories
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}/"
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

# Step 3. Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework/${PROJECT_NAME}"
