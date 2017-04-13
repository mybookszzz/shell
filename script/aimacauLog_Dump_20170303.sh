#!/usr/bin/bash

DATE=`date +%Y%m%d`
echo "当前日期为：		${DATE}"
Number=30
Sequence=`seq 0 ${Number}|sort -nr`
echo "备份至多向前		${Number}个天"
echo "即 可以备份的最早日期为：	`date -d "-${Number} day" +%Y%m%d`"
DataBase=AiMacauLog
TablePrefix=t_user_coins

read -p "是否要继续执行？(yes/no)"  Code1
if [ $Code1 == "no" ];then
exit
fi

HOST=
USER=
PASSWD= 

for i in ${Sequence}
do
DateTmp=`date -d "-${i} day" +%Y%m%d`
#DateTmp=201506
echo "当前正在导出	${DateTmp} 的所有表至t_user_coins${DateTmp}.sql"
TABLES=$(mysql -D AiMacauLog -Bse "show tables like 't_user_coins${DateTmp}%'")
echo "${DateTmp}	${TABLES}" | tee >>Log_Dump.log
if [ -z "${TABLES}" ];then
echo ${DateTmp} 月份表为空;
continue
fi
mysqldump --default-character-set=utf8mb4 AiMacauLog ${TABLES}  > AiMacauLog.t_user_coins${DateTmp}.sql
echo "${DateTmp}月份所有表已经导出..."
done

