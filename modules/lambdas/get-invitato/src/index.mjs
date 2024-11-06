import { HEADERS } from "./costants.mjs";
import { get_invitato } from "./utils/dynamo.mjs";

export async function handler(event) {
  try {
    console.log(event);
    const { id } = event.queryStringParameters;
    if (!id) {
      throw new Error('id mancante');
    }

    const response = (await get_invitato(id));

    console.log(response);

    return {
      statusCode: 200,
      headers: HEADERS,
      body: JSON.stringify({
        state: true,
        data: response
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