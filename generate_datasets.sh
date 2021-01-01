#!/bin/bash

# retrieve env variables check for more details on : https://www.emploi-store-dev.fr/portail-developpeur/application 
export EMPLOI_STORE_CLIENT_ID

export EMPLOI_STORE_CLIENT_SECRET


# Data on the number of sports, health, education, leisure and public services facilities in each municipality.
# https://www.eterritoire.fr/

# create datasets repository 
mkdir -p datasets

# declare an array variable
declare -a arr=(2A 2B 971 972 973 974 976)
# Initialisation with departments of : Corse du Sud, Haute Corse, Guadeloupe, Martinique, Guyane, La Réunion, Mayotte

# Append Array with departments from 1 to 19 then 21 to 95
for ((i=1;i<=19;i++)); 
do 
   arr+=($i);
done

for ((i=21;i<=95;i++)); 
do 
   arr+=($i);
done


# A token expires in 1499 seconds which is enough for this script to run fully
token=$(curl -v https://entreprise.pole-emploi.fr/connexion/oauth2/access_token?realm=%2Fpartenaire \
-d client_id=$EMPLOI_STORE_CLIENT_ID \
-d client_secret=$EMPLOI_STORE_CLIENT_SECRET \
-d scope=application_$EMPLOI_STORE_CLIENT_ID%20api_eterritoirev1 \
-d grant_type=client_credentials \
-H "Content-Type: application/x-www-form-urlencoded" \
| jq -r '.access_token')


# loop through the above array
for i in "${arr[@]}";
do

# department as parameter in url
printf -v url 'https://api.emploi-store.fr/partenaire/eterritoire/v1/cadre-de-vie.php?dep=%s' "$i"

printf -v authorisation 'Authorization: Bearer %s' "$token"
printf -v file 'datasets/%s.json' "$i"

# REST API request and the return as JSON is saved in a file in the format "[num_department].json"
curl --location --request GET "$url" \
--header "$authorisation" \
--header 'Cookie: IG_SESSIONID=3042C37EED4DCB6768F37D06CA9764BA; PHPSESSID=8nh8ktm3s2jklagj3p4j3jbf91; TS01600790=01b3abf0a257bb83d619f2f24736dd9b062c84afb9e22955ecb757e38e67c291fd6d153007245743ff0c589e8d43b47dff49e205be' \
-o $file

# Sleep 2 seconds between each iteration as API is limited to 2 calls per second
sleep 2;

done



