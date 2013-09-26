mvn package -P commons -Dmaven.test.skip=true
cp -r target/ourgrid-*-commons/ourgrid*/lib .
cp target/ourgrid*.jar ./lib