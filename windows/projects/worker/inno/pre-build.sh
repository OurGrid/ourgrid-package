mvn package -P commons -Dmaven.test.skip=true
cp -r target/ourgrid-*-commons/ourgrid*/lib .
cp target/ourgrid*.jar ./lib
inno/wget/wget.exe http://www2.lsd.ufcg.edu.br/~tarciso/VirtualBox/vbox-win32-bin.tar.gz
tar -xvf vbox-win32-bin.tar.gz