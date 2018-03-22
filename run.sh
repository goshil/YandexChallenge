#!/bin/bash

clear

ListOfChallenges=("# Поиск 5ти пользователей (с непустым идентификатором), сгенерировавших наибольшее количество запросов:"
'# Поиск 5ти пользователей (с непустым идентификатором), отправивших наибольшее количество данных:'
'# Поиск регулярных запросов (запросов выполняющихся периодически) (одинаковых, >=2) по полю src_user:'
'# Поиск регулярных запросов (запросов выполняющихся периодически) (одинаковых >=2) по полю src_ip:')

ListOfSolutions=("SELECT COUNT() AS queries, src_user FROM shkib GROUP BY src_user HAVING src_user !='' ORDER BY queries DESC LIMIT 5;"
"SELECT SUM(output_byte) AS total_bytes, src_user FROM shkib GROUP BY src_user HAVING src_user !='' ORDER BY total_bytes DESC LIMIT 5;"
"SELECT src_user,dest_user,dest_ip,dest_port,output_byte,COUNT() AS query_count FROM shkib GROUP BY src_user,dest_user,dest_ip,dest_port,output_byte HAVING query_count>=2 ORDER BY query_count DESC;"
"SELECT src_ip,dest_user,dest_ip,dest_port,output_byte,COUNT() AS query_count FROM shkib GROUP BY src_ip,dest_user,dest_ip,dest_port,output_byte HAVING query_count>=2 ORDER BY query_count DESC;")


echo -e "\nChecking and removing old files"
if [ -e shkib.db ] 
 then 
  rm shkib.db
fi
if [ -e result.txt ] 
 then 
  rm result.txt 
fi
echo ".done"

echo -e "\nImporting db..."
echo -e ".separator ","\n.import shkib.csv shkib"| sqlite3 shkib.db
echo ".done"

read -rsn1 -p $'\nResults will be output on screen and to "result.txt" file\nYou\'ll need to press any key after each stanza output\n\nPress any key to continue...'

for i in {0..3} 
do
 echo -e "\n\n${ListOfChallenges[$i]}\n" | tee -a result.txt
 read -rsn1 -p $'Press any key to continue...'
 echo -e "\nwait...\n"
 echo -e "$(echo -e ".mode column \n.headers on \n${ListOfSolutions[$i]}" | sqlite3 shkib.db)" | tee -a result.txt
done


echo -e "\n\nProcess finished, all data captured in result.txt, cleaning temp files..."
if [ -e shkib.db ] 
 then 
  rm shkib.db
fi
echo -e ".done\n"
read -rsn1 -p $'Press any key to exit...'
echo -e "\n\nbye.\n"
