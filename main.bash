if [[ -z "$DOMAINNAME" ]]
then
  DOMAINNAME=MyCompany
fi

if [[ -z "$PASS" ]]
then
  PASS="password"
fi

rm -rf bin
mkdir bin
cd bin

mkdir ca
cd ca

openssl req -new -newkey rsa:1024 -nodes -out ca.csr -keyout ca.key -config ../../serverdefaults.txt
openssl x509 -trustout -signkey ca.key -days 36500 -req -in ca.csr -out ca.pem
echo "02" > ca.srl

cd ..
mkdir java
cd java

keytool -genkey -dname "cn=$DOMAINNAME" -alias localhost -keyalg RSA -keystore keystore.jks -keypass $PASS -storepass $PASS
keytool -import -keystore keystore.jks -file ../ca/ca.pem -alias selfca

# cd ..
# mkdir client
# cd client

# FILE="users.txt"

# oIFS="$IFS"
# IFS=";"

# while read name email; do
# 	echo "--"
# 	echo $name
# 	echo $email
# done < <(grep '' $FILE)


# IFS="$oIFS"
# unset oIFS