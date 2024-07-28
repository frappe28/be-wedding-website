import { HEADERS } from "./costants.mjs";
import { check_invitato } from "./utils/dynamo.mjs";

export async function handler(event) {
  try {
    console.log(event);
    const { nome, cognome } = event.queryStringParameters;
    const response = (await check_invitato(nome.toLowerCase() + cognome.toLowerCase())).itemResult;
    console.log(response);
    let isInvitato = false;
    if (response != null && response.nome != null && response.cognome != null)
      isInvitato = true


    return {
      statusCode: 200,
      headers: HEADERS,
      body: JSON.stringify({ state: isInvitato, message: (isInvitato ? 'Invitato!' : 'Non Invitato') })
    };
  } catch (error) {
    console.log(error)
    return {
      statusCode: 500,
      headers: HEADERS,
      body: JSON.stringify({ state: false, message: error.message })
    };
  }

}