import { HEADERS } from "./costants.mjs";
import { get_tavolo } from "./utils/dynamo.mjs";


export async function handler(event) {
  console.log('event', event);
  try {
    const id = event.queryStringParameters.id;
    const tavolo = await get_tavolo(id);
    console.log(tavolo);

    return { statusCode: 200, headers: HEADERS, body: JSON.stringify(tavolo) };
  } catch (error) {
    console.error(error);
    return { statusCode: 500,  headers: HEADERS, body: 'Errore nel recupero del tavolo' };
  }
};
