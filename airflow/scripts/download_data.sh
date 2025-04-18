#!/usr/bin/env bash

# Define constants for maintainability
DATA_DIR="/opt/airflow/data/raw"
DATASET_NAME="global-fashion-retail-stores-dataset"
KAGGLE_URL="https://www.kaggle.com/api/v1/datasets/download/ricgomes/${DATASET_NAME}"
ZIP_FILE="${DATA_DIR}/${DATASET_NAME}.zip"

# Logging function with timestamp
log() {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[${timestamp}] INFO: $*"
}

log "Script started, processing fashion retail stores dataset"

# Create data directory
mkdir -p "${DATA_DIR}" || {
    log "ERROR: Failed to create data directory ${DATA_DIR}"
    exit 1
}

# Download dataset
log "Downloading dataset from Kaggle..."
curl --fail --silent --location --output "${ZIP_FILE}" "${KAGGLE_URL}" || {
    log "ERROR: Download failed. Check network connection or Kaggle URL"
    rm -f "${ZIP_FILE}"  # Cleanup partial download
    exit 1
}

# Verify ZIP file
if [[ ! -f "${ZIP_FILE}" ]]; then
    log "ERROR: ZIP file not found after download"
    exit 1
fi

# Extract files
log "Extracting files to ${DATA_DIR}..."
unzip -o -q "${ZIP_FILE}" -d "${DATA_DIR}" || {
    log "ERROR: Extraction failed. File may be corrupted"
    exit 1
}

# Cleanup
log "Cleaning temporary files..."
rm -f "${ZIP_FILE}"

# Verify extraction
if [[ -z $(ls -A "${DATA_DIR}") ]]; then
    log "ERROR: Data directory is empty after extraction"
    exit 1
fi

log "Processing completed! Data files available at: ${DATA_DIR}"