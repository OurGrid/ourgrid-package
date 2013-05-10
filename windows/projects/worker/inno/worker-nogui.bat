setlocal
cd %~dp0
set OGROOT=[[OGROOT]]
start /b javaw -cp .;./lib/* -Dlog4j.configuration="file:[[LOG4J]]" -Dvbox.home="[[VBOXBIN]]" -Xms64m -Xmx1024m org.ourgrid.worker.ui.sync.Main start
endlocal