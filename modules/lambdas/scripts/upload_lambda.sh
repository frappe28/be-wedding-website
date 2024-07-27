#!/bin/bash

# Variables
# List of lambda names
NAMES=("controllo-invitato")
LAMBDA_DIR="../controllo-invitato"
DIST_DIR="$LAMBDA_DIR/dist"
ZIP_FILE="dev-francis-wedding-$NAME.zip"
S3_BUCKET="dev-francis-wedding-lambdas"

export AWS_PROFILE=wedding

for NAME in "${NAMES[@]}"
do
    # Step 1: Navigate to the lambda directory
    cd $LAMBDA_DIR

    # Step 2: Install dependencies and build the project
    rm -rf dist
    yarn install
    yarn build

    # Step 3: Create a zip file with the contents of the dist directory
    cd $DIST_DIR
    zip -r ../../scripts/$ZIP_FILE .
    cd ../../scripts/

    # Step 4: Upload the zip file to the specified S3 bucket
    aws s3 cp $ZIP_FILE s3://$S3_BUCKET/

    # Step 5: Clean up
    rm $ZIP_FILE
    echo "Lambda deployment package for $NAME created and uploaded to S3 successfully."

    # Navigate back to the original directory for the next iteration
    cd -
done