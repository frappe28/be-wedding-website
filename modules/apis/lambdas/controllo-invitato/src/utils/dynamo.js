import { DynamoDB } from 'aws-sdk';
import { DYNAMODB_INVITATI_TABLE_NAME, REGION } from "../costants";

const dynamodbClient = new DynamoDB.DocumentClient({
    region: REGION
});

export const check_invitato = async (id) => {
    try {
        const params = {
            TableName: DYNAMODB_INVITATI_TABLE_NAME,
            Key: {
                PK: id
            }
        };
        logger.info('Get otp management item params', { ...params });
        const queryResult = await dynamodbClient.get(params).promise();
        logger.info('Get otp management item result', { ...queryResult });
        const itemResult = queryResult.Item;

        return {
            itemResult
        };

    } catch (error) {
        throw new DynamoDBException();
    }
};