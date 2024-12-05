#!/bin/bash

# Configurazione variabili
TABLE_NAME="prod-francis-wedding-invitati"  # Sostituisci con il nome della tua tabella DynamoDB
CSV_FILE="test.csv"  # Percorso al tuo file CSV

# Funzione per generare l'ID
generate_id() {
    local nome=$1
    local cognome=$2
    local anno_nascita=$3
    # Estrae le ultime due cifre dell'anno di nascita e le concatena con nome e cognome
    echo "${nome}${cognome}${anno_nascita:2:2}"
}

clean_and_lowercase() {
    # Rimuove spazi, caratteri speciali e converte in minuscolo
    echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d -c '[:alnum:]' | tr '[:upper:]' '[:lower:]'
}
clean() {
   echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' 
}

# Leggi il CSV e crea i record in DynamoDB
while IFS=',' read -r ID NOME COGNOME NEONATO ANNO_DI_NASCITA USERNAME EMAIL TELEFONO FORESTIERO INTOLLERANZE INTOLLERANZE_LIST INVITO NOTE_FORESTIERO GRUPPO INVITATO CONFERMATO MENU TAVOLO SESSO; do
    # Salta la prima riga (intestazioni)
    if [ "$ID" == "ID" ]; then
        continue
    fi
    NOMEPULITO=$(clean_and_lowercase "$NOME")
    COGNOMEPULITO=$(clean_and_lowercase "$COGNOME")
    INVITO=$(clean_and_lowercase "$INVITO")
    ANNO_DI_NASCITA=$(clean_and_lowercase "$ANNO_DI_NASCITA")

    # Crea l'ID usando la logica di concatenazione
    GENERATED_ID=$(generate_id "$NOMEPULITO" "$COGNOMEPULITO" "$ANNO_DI_NASCITA")

    NOME=$(clean "$NOME")
    COGNOME=$(clean "$COGNOME")

    # Crea il record da inserire con formato corretto per DynamoDB
    ITEM_JSON=$(jq -n \
        --arg id "$GENERATED_ID" \
        --arg nome "$NOME" \
        --arg cognome "$COGNOME" \
        --arg invito "$INVITO" \
        '{
            id: {S: $id},
            nome: {S: $nome},
            cognome: {S: $cognome},
            invito: {S: $invito}
        }')

    # Inserisci il record in DynamoDB
    aws dynamodb put-item \
        --table-name "$TABLE_NAME" \
        --item "$ITEM_JSON"

    echo "Inserito record con ID: $GENERATED_ID"
done < "$CSV_FILE"