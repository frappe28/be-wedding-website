import { HEADERS } from "./costants.mjs";
import { update_invitato } from "./utils/dynamo.mjs";

export async function handler(event) {
  try {
    console.log(event);
    const invitato = JSON.parse(event.body);

    const response = await update_invitato(invitato);
    console.log(response);

    return {
      statusCode: 200,
      headers: HEADERS,
      body: JSON.stringify({
        status: true,
        message: 'Presenza Confermata'
      })
    };
  } catch (error) {
    console.log(error)
    return {
      statusCode: 500,
      headers: HEADERS,
      body: JSON.stringify({
        status: false,
        message: error.message
      })
    };
  }

}