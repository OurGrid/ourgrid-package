mvn package -P commons -Dmaven.test.skip=true
cp -r target/ourgrid-*-commons/ourgrid*/lib .
cp target/ourgrid*.jar ./lib
mkdir -p qemu-win32-bin
cd qemu-win32-bin
../inno/wget/wget.exe http://maven.ourgrid.org/repos/linux/qemu/linux-qemu/qemu-win32.tar.gz
tar -xvf qemu-win32.tar.gz
rm qemu-win32.tar.gz