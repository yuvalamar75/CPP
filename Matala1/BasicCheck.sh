#!/bin/bash

#this file check a directory that include makefile and check 3 things
#check if the file can compile,check if there are leak of memory and check therd race.


folderName=$1
filename=$2

shift 2
curentLocation=`pwd`
checksum=0

cd $folderName

make &>/dev/null #print the output to null file and not to the terminal
succesfullMake=$?

#case 1: compilation error- check if able to compile.
if [ $succesfullMake -gt 0 ]; then
echo "compilation    memoryleaks     thread race"
echo "fail 		   fail  		  fail"
cd $curentLocation
exit 7
fi

#test 2: check if there is any memory leak.
valgrind --leak-check=full --error-exitcode=2 ./$filename $@ &>/dev/null
valresult=$?
if [ $valresult -gt 0 ]; then
let "checksum=$checksum+$valresult"
fi

#test 3: check if there is threadrace error.
valgrind --tool=helgrind --error-exitcode=1 ./$filename $@ &>/dev/null
helresult=$?
if [ $helresult -gt 0 ];then
let "checksum=$checksum+$helresult"
fi

#print the the type of error
echo "compilation    memoryleaks     thread race"
if [ "$checksum" -eq 0 ]; then
echo "pass		    pass    		pass"
fi

if [ "$checksum" -eq 1 ]; then
echo "pass	 	   pass    	     fail"
fi

if [ "$checksum" -eq 2 ]; then
echo "pass		    fail    		pass"
fi

if [ "$checksum" -eq 3 ]; then	
echo "pass 		   fail   		fail"
fi


cd $curentLocation
exit $checksum
