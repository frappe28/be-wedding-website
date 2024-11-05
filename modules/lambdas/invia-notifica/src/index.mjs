import { scanInvitati } from "./utils/dynamo.mjs";
import { sendNotification } from "./utils/sns.mjs";


export async function handler(event) {
  console.log('event', event);
  try {
    // Leggi gli invitati da DynamoDB
    const inviati = await scanInvitati();
    console.log(inviati);

    const promises = [];

    //Itera su ogni elemento (invitato)
    inviati.forEach(invitato => {
      if (invitato.telefono && invitato.nome)
        promises.push(sendNotification(invitato.nome, invitato.telefono, event.messaggio))
    });

    // Invia tutti i messaggi
    await Promise.all(promises);
    return { statusCode: 200, body: 'Messaggi inviati con successo!' };
  } catch (error) {
    console.error(error);
    return { statusCode: 500, body: 'Errore nell\'invio dei messaggi.' };
  }
};
