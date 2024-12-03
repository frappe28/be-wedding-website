import pkg from 'aws-sdk';
const { SNS } = pkg;

const snsClient = new SNS();

export const sendNotification = async (nome, email, messaggio) => {
    const snsParams = {
        Subject: `STAY UP TO DATE`,
        Message: `Ciao ${nome},\n\n${messaggio}`,
        TopicArn: 'arn:aws:sns:eu-west-1:992382446823:dev-francis-wedding-notifica-invitati'
    };
    return snsClient.publish(snsParams).promise();
}