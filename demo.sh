#! BIN/BASH
echo "Name", "Email", "Repo Link", "Clone Status", "Build Status", "CPPcheck errors", "Valgrind Pass cases" > Results.csv 
while IFS=, read -r name email repo; do

  [[ "$name" != "Name" ]] && echo "$name"
  [[ "$email" != "Email ID" ]] && echo "$email"
  if [ "$repo" != "Repo link" ]; then
    git clone "$repo"
    if [ "$?" == 0 ]; then
      CLONE_STAT="Clone Successful"
    else
      CLONE_STAT="Clone Failed"
    fi
    reponame=`echo $repo | cut -d'/' -f5`
    BUILD=`find $reponame -name Makefile -exec dirname {} \;`
    make -C $BUILD
    make run -C $BUILD
    if [ "$?" == 0 ]; then
      BUILD_SUCC="Build Successful"
    else
      BUILD_SUCC="Build Failed"
    fi
    ERR=`cppcheck $reponame | grep 'error' | wc -l`        
    make test -C $BUILD
    FIN_VAL=`find "$BUILD" -name "Test*.out"`
    echo "dir = $FIN_VAL"
    valgrind "./$FIN_VAL" 2> valgrinr.csv
    VALG=`grep "ERROR SUMMARY" valgrinr.csv`
    echo "ERR = ${VALG:25:1}"
    echo "$name, $email, $repo, $CLONE_STAT, $BUILD_SUCC, $ERR, ${VALG:25:1}" > Results.csv      
  fi
    
done < Input.csv
