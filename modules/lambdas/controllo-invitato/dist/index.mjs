import { HEADERS } from "./costants.mjs";
import { check_invitato } from "./utils/dynamo.mjs";

export async function handler(event) {
  try {
    console.log(event);
    const { nome, cognome, anno } = event.queryStringParameters;
    if (!nome || !cognome) {
      throw new Error('Nome e cognome sono obbligatori');
    }
    let id = nome.toLowerCase() + cognome.toLowerCase();

    if (anno) {
      const yearNum = parseInt(anno);
      if (isNaN(yearNum) || (yearNum <= 1930 && yearNum >= 2025)) {
        throw new Error('Anno non valido');
      }

      id += anno.slice(-2);
    }

    const response = (await check_invitato(id));
    console.log(response);
    let result;
    let isInvitato = false;
    if (response.Count == 1) {
      result = response.Items[0];
      if (result.id === id) {
        isInvitato = true;
      }
    } else if (response.Count > 1) {
      result = response.Items;
      isInvitato = false
    } else {
      isInvitato = false;
    }

    return {
      statusCode: 200,
      headers: HEADERS,
      body: JSON.stringify({
        state: isInvitato,
        message: (isInvitato ? 'Invitato!' : 'Non Invitato'),
        data: result
      })
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