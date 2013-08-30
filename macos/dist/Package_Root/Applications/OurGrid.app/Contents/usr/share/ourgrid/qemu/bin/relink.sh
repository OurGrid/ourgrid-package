otool -L $1 | tail -n +2 > $1.libs

while read -r LIB_LINE; do
  FULL_LIB_PATH=`echo $LIB_LINE | awk '{print $1}'`
  LIB_NAME=`basename "$FULL_LIB_PATH"`
  if [ -f $LIB_NAME ]; then
    install_name_tool -change $FULL_LIB_PATH @executable_path/$LIB_NAME $1 
    echo $LIB_NAME
  fi
done < $1.libs
