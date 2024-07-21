exports.handler = async (event) => {
  console.log(event);
  const { nome, cognome } = event.queryStringParameters;

  return {
    statusCode: 200,
    body: JSON.stringify({
      nome,
      cognome
    })
  };
};