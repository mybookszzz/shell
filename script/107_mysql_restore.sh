#!/bin/bash

SQL_all=`ls *.sql`
Error_file=error.log
read -p "开始之前请设置要导入哪些sql文件,确定开始导入么(yes/no)" choose1
if [ $choose1 = "yes" ];then
echo "开始导入数据"
else
exit 1
fi

for i in $SQL_all
do
echo "begin	$i"
mysql --default-character-set=utf8mb4 AiMacauLog < $i
if [ $? -eq 0 ];then
echo "finish	$i"
else
echo "$i has some problems" | tee -a error.log
fi
done
