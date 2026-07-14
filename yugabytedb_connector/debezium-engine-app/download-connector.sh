#!/bin/bash

# Script to download and install the YugabyteDB PostgreSQL Connector JAR to local Maven repository

VERSION="dz.2.5.2.yb.2025.1.2"
GROUP_ID="io.debezium"
ARTIFACT_ID="yugabytedb-source-connector"
JAR_NAME="${ARTIFACT_ID}-${VERSION}-jar-with-dependencies.jar"
GITHUB_URL="https://github.com/yugabyte/debezium/releases/download/${VERSION}/${JAR_NAME}"

echo "Downloading YugabyteDB PostgreSQL Connector JAR from GitHub..."

# Create temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download the connector JAR from GitHub
wget "$GITHUB_URL"

if [ $? -ne 0 ]; then
    echo "Failed to download connector JAR from GitHub"
    rm -rf "$TMP_DIR"
    exit 1
fi

echo "Successfully downloaded connector JAR"
echo "Installing to local Maven repository..."

# Install the JAR to local Maven repository
mvn install:install-file \
    -Dfile="$JAR_NAME" \
    -DgroupId="$GROUP_ID" \
    -DartifactId="$ARTIFACT_ID" \
    -Dversion="$VERSION" \
    -Dpackaging=jar \
    -DgeneratePom=true

if [ $? -eq 0 ]; then
    echo "Successfully installed connector JAR to local Maven repository"
    echo "Location: ~/.m2/repository/${GROUP_ID//.//}/${ARTIFACT_ID}/${VERSION}/"
else
    echo "Failed to install connector JAR to Maven repository"
    rm -rf "$TMP_DIR"
    exit 1
fi

# Cleanup
cd - > /dev/null
rm -rf "$TMP_DIR"

echo "Done! You can now build the application with 'mvn clean package'"

