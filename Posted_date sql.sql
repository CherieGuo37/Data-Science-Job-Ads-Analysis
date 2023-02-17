with date_cet as 
(
select id, 
       SUBSTRING(date,CHARINDEX(' ',date),3) as NumberofDays      
from data_science_jobs_indeed_usa
),
date_cet2 as 
(
select  id,
        case 
        when Numberofdays like '%po%' then '0'
		when Numberofdays like '%on%' then '-100'
		else NumberofDays
		end as daysapart
from date_cet 

)
select id,
       cast  (dateadd(day,-cast(daysapart as int), '2022-11-20')  as date) as Posted_date
from date_cet2
order by id