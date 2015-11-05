if [[ -z "$DOMAINNAME" ]]
then
  DOMAINNAME=MyCompany
fi

if [[ -z "$PASS" ]]
then
  PASS="aicigaicig"
fi

rm -rf bin
mkdir bin
cd bin

mkdir ca
cd ca

openssl req -new -newkey rsa:1024 -days 36500 -nodes -out ca.csr -keyout ca.key -config ../../serverdefaults.txt
openssl x509 -trustout -signkey ca.key -req -in ca.csr -out ca.pem -days 36500
echo "02" > ca.srl

cd ..
mkdir java
cd java

keytool -genkey -dname "cn=$DOMAINNAME" -alias localhost -keyalg RSA -keystore keystore.jks -keypass $PASS -storepass $PASS
keytool -import -keystore keystore.jks -file ../ca/ca.pem -alias selfca

cd ..
mkdir client
cd client

FILE="../../users.txt"

oIFS="$IFS"
IFS=";"

while read name email; do

  openssl req -new -newkey rsa:1024 -nodes -out ${name}.req -keyout ${name}.key -subj "/C=US/ST=Virginia/CN=${name}/EMAILADDRESS=aicig-${email}" -days 36500
  openssl x509 -CA ../ca/ca.pem -CAkey ../ca/ca.key -CAserial ../ca/ca.srl -req -in ${name}.req -out ${name}.pem -days 36500
  openssl pkcs12 -export -in ${name}.pem -inkey ${name}.key -out ${name}.p12 -name "${name}"

done < <(grep '' $FILE)

IFS="$oIFS"
unset oIFS