
--1. Change Posted_Date value from "PostedPosted 26 days ago" to "yyyy-mm-dd" format
--( The data was web scraped from indeed web portalon Nov 20, 2022)

with date_cet as 
(
select SUBSTRING(date,CHARINDEX(' ',date),3) as NumberofDays, 
        
      date
from data_science_jobs_indeed_usa

),
date_cet2 as 
(
select   case 
        when Numberofdays like '%po%' then '0'
		when Numberofdays like '%on%' then '-100'
		else NumberofDays
		end as daysapart
from date_cet 

)
select  cast  (dateadd(day,-cast(daysapart as int), '2022-11-20')  as date) as Posted_date
from date_cet2
order by Posted_date asc


-- 2.Extract the maximum and minimum salary per hour from Salary(ex:$80 - $120 an hour) 
with salaryperhour_cet as
(
select  id,
       replace( left(salary, charindex('a',Salary,1)-1),'$','') as salary_per_hour,
        Salary
		
from data_science_jobs_indeed_usa
where Salary like '%hour%'
)
select id, 
       case 
	   when salary_per_hour like 'from%' then substring (salary,charindex('$',salary)+1,3)
	   else  left(salary_per_hour, charindex('- ',salary_per_hour)) 
	   end as  minimum_per_hour ,
	   case 
	   when salary_per_hour like 'up%' then substring (salary,charindex('$',salary)+1,3)
	   else  right (salary_per_hour, charindex('- ',salary_per_hour)) 
	   end as  maximum_per_hour, 
	   case 
	   when len(salary_per_hour)<=3 then left(salary_per_hour,3)
	   end as fixed_per_hour,
	   salary_per_hour,
	   Salary
	  
from salaryperhour_cet


--3.Extract the maximum and minimum  annaul salary  from Salary(ex:$90,000 - $110,000 a year) 

with salaryperyear_cet as
(
select  id,
        Salary,
       replace( left(salary, charindex('a',Salary,1)-1),'$','') as salary_per_year
from data_science_jobs_indeed_usa
where Salary like '%year%'
)

select id, 
       case 
	   when salary_per_year like 'from%' then substring (salary,charindex('$',salary)+1,7)
	   else  left(salary_per_year, charindex('- ',salary_per_year)) 
	   end as  minimum_per_year ,
	   case 
	   when salary_per_year like 'up%' then substring (salary,charindex('$',salary)+1,7)
	   else  right (salary_per_year, charindex('- ',salary_per_year)) 
	   end as  maximum_per_year, 
	   case 
	   when len(salary_per_year)<=7 then left(salary_per_year,8)
	   end as fixed_per_year,
	   salary_per_year,
	   Salary
from salaryperyear_cet

-- 4. use strin_split to count the skills mentioned in job description 
with cet1 as 
(SELECT 
       
       value [descriptions]
     , COUNT(*) [#times] 
FROM data_science_jobs_indeed_usa
CROSS APPLY STRING_SPLIT(Descriptions, ' ')
GROUP BY value

)
,
cet2 as
(
select 
     descriptions,
       [#times], 
	   case when descriptions like '%SQL%' then #times else null  end as sql_skills,
	    case when descriptions like '%python%' then #times else null  end as python_skills,
	   case when descriptions like '%datalake%' then #times else null  end as datalake_skills,
	   case when descriptions like '%excel' then #times else null  end as excel_skills


from cet1
)
select 
     
	   sum(sql_skills) as total_sql,
	   sum(python_skills) as total_python,
	   sum(datalake_skills) as total_datalake,
	   sum(excel_skills) as total_excel
from cet2