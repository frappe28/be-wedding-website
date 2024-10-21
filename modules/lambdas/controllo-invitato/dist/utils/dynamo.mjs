import pkg from 'aws-sdk';
import { DYNAMODB_INVITATI_TABLE_NAME, REGION } from "../costants.mjs";
const { DynamoDB } = pkg;

const dynamodbClient = new DynamoDB.DocumentClient({
    region: REGION
});

export const check_invitato = async (id) => {
    try {
        const params = {
            TableName: DYNAMODB_INVITATI_TABLE_NAME,
            FilterExpression: 'begins_with(#id, :idPrefix)',
            ExpressionAttributeNames: {
                '#id': 'id'
            },
            ExpressionAttributeValues: {
                ':idPrefix': id
            }
        };

        console.log('Scan params', { ...params });
        const queryResult = await dynamodbClient.scan(params).promise();
        console.log('Scan result', { ...queryResult });

        return queryResult;

    } catch (error) {
        throw new Error(error.message);
    }
};
