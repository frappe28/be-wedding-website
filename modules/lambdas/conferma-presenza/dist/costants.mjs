export const DYNAMODB_INVITATI_TABLE_NAME = process.env.DYNAMODB_INVITATI_TABLE_NAME || '';
export const REGION = process.env.REGION || 'eu-west-1';
export const HEADERS = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Headers': 'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token,x-requested-with,Access-Control-Allow-Origin,accesstoken,idtoken',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'OPTIONS,POST',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains'
};