#!/bin/bash
function insert(){
	sed -i '/<project name=*/ a xmlns:ekstazi="antlib:org.ekstazi.ant"' build.xml
	sed -i '/<\/project>/i <taskdef uri="antlib:org.ekstazi.ant" resource="org/ekstazi/ant/antlib.xml">\
	<classpath path="org.ekstazi.core-4.5.2.jar"/>\
	<classpath path="org.ekstazi.ant-4.5.2.jar"/>\
	</taskdef>' build.xml
	sed -i '/<junit*/i <ekstazi:select>' build.xml
	sed -i '/<\/junit>/a </ekstazi:select>' build.xml
}
cd ~
rm -rf zookeeper
git clone https://github.com/apache/zookeeper
cd zookeeper
wget http://www.ekstazi.org/release/org.ekstazi.core-4.5.2.jar
wget http://www.ekstazi.org/release/org.ekstazi.ant-4.5.2.jar
rev=()
for i in $(seq 10)
do
	rev+=(`git log | grep "^commit " | head -n ${i} | tail -n 1 | cut -c 8-14`)
done
i=9
for((i=9; i >= 0;i--))
do
	git reset --hard "${rev[${i}]}"
	insert
	echo "dependencies.ignored.paths = /Info" > .ekstazirc
	ant test &>out${rev[${i}]}.txt
	wait
done
echo "Revision, Number of tests, Total time" >> result.csv
for i in $(seq 0 9)
do
	echo ${rev[${i}]}","`grep -c "\[junit] Tests run:" out${rev[${i}]}.txt`", "`grep "Total time:" out${rev[${i}]}.txt| cut -d ' ' -f 3-` >> result.csv
done
