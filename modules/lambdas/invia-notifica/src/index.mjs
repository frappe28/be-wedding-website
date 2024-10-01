import { scanInvitati } from "./utils/dynamo.mjs";
import { sendNotification } from "./utils/sns.mjs";


export async function handler(event) {
  console.log('event', event);
  try {
    // Leggi gli invitati da DynamoDB
    const inviati = await scanInvitati();
    console.log(inviati);

    //Itera su ogni elemento (invitato)
    const promises = inviati.itemResult.map(async invitato => {
      if (invitato.telefono)
        await sendNotification(invitato.nome, invitato.telefono, event.messaggio)
    });

    // Invia tutti i messaggi
    await Promise.all(promises);
    return { statusCode: 200, body: 'Messaggi inviati con successo!' };
  } catch (error) {
    console.error(error);
    return { statusCode: 500, body: 'Errore nell\'invio dei messaggi.' };
  }
};
