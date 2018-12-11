##Stats 506, F18, Problem Set 4, Question 1
##
##Compute the all-time leader in hits for each birth country  
##Data from Lahman baseball data seen in our class
##SQL query
##
##Author: Xun Wang, xunwang@umich.edu
##Updated: December 5,2018- Lasted modified date

#80:--------------------------------------------------------------------------

#Libraries:-------------------------------------------------------------------
library(tidyverse)
library(dbplyr)
library(Lahman)

##Create a local SQLlite database:---------------------------------------------
lahman = lahman_sqlite()

##format a table with player name, debut data, birth Country and total hits:---
all_time_leader=lahman%>%
  tbl(sql('
          SELECT nameFirst,nameLast,debut,birthCountry,max(total_hits) AS Hits
          FROM (SELECT playerID,sum(H) AS total_hits
                FROM batting
                GROUP BY playerID
                ) b
          LEFT JOIN
            (SELECT *
             FROM master
             ) m
          ON m.playerID=b.playerID
          GROUP BY birthCountry
          HAVING Hits>200
          ORDER BY -Hits
          '))%>%collect()

#80:--------------------------------------------------------------------------
