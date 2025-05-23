#!/bin/bash

# Variables
# List of lambda names
#NAMES=("controllo-invitato")
NAMES=("conferma-presenza")
#NAMES=("get-invitato")
S3_BUCKET="prod-francis-wedding-lambdas"

export AWS_PROFILE=wedding

for NAME in "${NAMES[@]}"
do
    LAMBDA_NAME="prod-francis-wedding-$NAME"
    LAMBDA_DIR="../$NAME"
    DIST_DIR="$LAMBDA_DIR/dist"
    ZIP_FILE="prod-francis-wedding-$NAME.zip"
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
    
    # NOTA BENE se crei la lambda per la prima volta commenta il seguente comando:
    aws lambda update-function-code \
    --function-name $LAMBDA_NAME \
    --s3-bucket $S3_BUCKET \
    --s3-key $ZIP_FILE

    # Step 5: Clean up
    rm $ZIP_FILE
    echo "Lambda deployment package for $NAME created and uploaded to S3 successfully."

    # Navigate back to the original directory for the next iteration
    cd -
done