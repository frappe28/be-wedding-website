import pkg from 'aws-sdk';
const { SNS } = pkg;

const snsClient = new SNS();

export const sendNotification = async (nome, telefono, messaggio) => {
    const snsParams = {
        Message: `Ciao ${nome}, ${messaggio}`,
        PhoneNumber: telefono.includes('+39') ? telefono : `+39${telefono}`,
        MessageAttributes: {
            'AWS.SNS.SMS.SenderID': {
                DataType: 'String',
                StringValue: 'WEDDING'
            }
        }
    };
    return snsClient.publish(snsParams).promise();
}