setlocal
set OGROOT=[[OGROOT]]
start /b javaw -cp .;./lib/* -Dlog4j.configuration="file:[[LOG4J]]" -Dqemu.home="[[QEMUBIN]]" -Xms64m -Xmx1024m org.ourgrid.worker.ui.async.Main
endlocal