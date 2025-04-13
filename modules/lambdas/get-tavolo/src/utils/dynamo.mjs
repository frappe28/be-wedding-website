import pkg from 'aws-sdk';
import { DYNAMODB_INVITATI_TABLE_NAME, REGION } from "../costants.mjs";
const { DynamoDB } = pkg;

const dynamodbClient = new DynamoDB.DocumentClient({
    region: REGION
});

export const get_tavolo = async (id) => {
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
            tavolo_numero: itemResult.tavolo_numero,
            tavolo_titolo: itemResult.tavolo_titolo
        };
    } catch (error) {
        throw new Error(error.message);
    }
};
