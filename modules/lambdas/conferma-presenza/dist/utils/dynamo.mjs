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
            Key: { id: invitato.id },
            UpdateExpression: "set conferma = :conferma, email = :email, intolleranze = :intolleranze, intolleranze_list = :intolleranze_list, telefono = :telefono, username = :username",
            ExpressionAttributeValues: {
                ":conferma": invitato.conferma,
                ":email": invitato.email,
                ":intolleranze": invitato.intolleranze,
                ":intolleranze_list": invitato.intolleranze_list,
                ":telefono": invitato.telefono,
                ":username": invitato.username
            },
            ReturnValues: "ALL_NEW"
        };

        console.log('Update item params', { ...params });
        const queryResult = await dynamodbClient.update(params).promise();
        console.log('Update item result', { ...queryResult });

        return queryResult.Attributes;

    } catch (error) {
        throw new Error(error.message);
    }
};
