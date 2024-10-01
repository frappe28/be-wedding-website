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
            Key: {
                id
            }
        };
        console.log('Get item params', { ...params });
        const queryResult = await dynamodbClient.get(params).promise();
        console.log('Get item result', { ...queryResult });
        const itemResult = queryResult.Item;

        return {
            itemResult
        };

    } catch (error) {
        throw new Error(error.message);
    }
};

export const scanInvitati = async () => {
    try {
        const params = {
            TableName: DYNAMODB_INVITATI_TABLE_NAME,
        };
        console.log('Get item params', { ...params });
        const queryResult = await dynamodbClient.scan(params).promise();
        console.log('Get item result', { ...queryResult });
        const itemResult = queryResult.Items;

        return itemResult;

    } catch (error) {
        throw new Error(error.message);
    }
};