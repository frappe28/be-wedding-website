import pkg from 'aws-sdk';
import { DYNAMODB_INVITATI_TABLE_NAME, REGION } from "../costants.mjs";
const { DynamoDB } = pkg;

const dynamodbClient = new DynamoDB.DocumentClient({
    region: REGION
});

export const get_invitato = async (id) => {
    try {
        const params = {
            TableName: DYNAMODB_INVITATI_TABLE_NAME,
            Key: {
                id: id
            }
        };
        console.log('Get item params', { ...params });
        const queryResult = await dynamodbClient.get(params).promise();
        console.log('Get result', { ...queryResult });

        return queryResult.Item;

    } catch (error) {
        throw new Error(error.message);
    }
};
