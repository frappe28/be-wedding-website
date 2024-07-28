import pkg from 'aws-sdk';
import { DYNAMODB_INVITATI_TABLE_NAME, REGION } from "../costants.mjs";
const { DynamoDB } = pkg;

const dynamodbClient = new DynamoDB.DocumentClient({
    region: REGION
});

export const update_invitato = async (invitato) => {
    try {
        const params = {
            TableName: DYNAMODB_INVITATI_TABLE_NAME,
            Item: invitato
        };
        console.log('Get item params', { ...params });
        const queryResult = await dynamodbClient.put(params).promise();
        console.log('Get item result', { ...queryResult });
        const itemResult = queryResult.Item;

        return {
            itemResult
        };

    } catch (error) {
        throw new Error(error.message);
    }
};
