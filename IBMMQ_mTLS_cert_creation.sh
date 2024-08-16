qmName=qm1
qmPassword=password

appName=app
appPassword=password

echo "[*] Starting mTLS certificate creation"

## create directories for storing certificates
mkdir client-cert
mkdir server-cert

## move to server-cert directory
cd server-cert
##
echo "Creating QM/server keystore/key database"
echo ">>"
runmqakm -keydb -create -db key.kdb -pw $qmPassword -stash
#"Creating the server certificate and put it in the new keystore key.kdb"
runmqakm -cert -create -db key.kdb -stashed -dn "cn=qm,o=ibm,c=uk" -label ibmwebspheremq$qmName
#" Extracting the queue manager's public key"
runmqakm -cert -extract -label ibmwebspheremq$qmName -db key.kdb -stashed -file QM.cert
cd ..

## move to client-cert directory
cd client-cert
##
echo "Creating client keystore/key database"
echo ">>"
runmqakm -keydb -create -db client.kdb -pw $appPassword -stash
#"current certificates in the keystore"
runmqakm -cert -create -db client.kdb -stashed -dn "cn=qm,o=ibm,c=uk" -label ibmwebspheremq$appName
#Extract the client's public key
runmqakm -cert -extract -label ibmwebspheremq$appName -db client.kdb -stashed -file Client.cert
cd ..


## Exchange public keys
echo "Exchanging public keys"
echo ">>"

runmqakm -cert -add -label ibmwebspheremq$qmName -db client-cert/client.kdb -stashed -file server-cert/QM.cert
runmqakm -cert -list -db client-cert/client.kdb -stashed
echo "client.kdb is ready"
echo ">>"

runmqakm -cert -add -label ibmwebspheremq$appName -db server-cert/key.kdb -stashed -file client-cert/Client.cert
runmqakm -cert -list -db server-cert/key.kdb -stashed
echo "server.kdb is ready"
echo ">>"

echo "[*] Completed mTLS certificate creation"



