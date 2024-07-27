import { check_invitato } from "./utils/dynamo.mjs";

export async function handler(event) {
  console.log(event);
  const { nome, cognome } = event.queryStringParameters;
  const response = (await check_invitato(nome.toLowerCase() + cognome.toLowerCase())).itemResult;
  console.log(response);
  let isInvitato = false;
  if (response != null && response.nome != null && response.cognome != null)
    isInvitato = true


  return {
    statusCode: 200,
    body: (isInvitato ? 'Invitato!' : 'Non Invitato')
  };
}