
--Remove the column "years_of_experience". Most of the data in this column is incorrect.
alter table remote_work 
drop column years_of_experience

--Calculate the average age of employees for each work location.
select distinct work_location
	, round(avg(age) over(partition by work_location),2) as average_age
from remote_work 

--Determination of the number of employees who have access to mental health resources and who have high levels of stress
select count(*)
from remote_work 
where access_to_mental_health_resources like ('Yes')
	and stress_level like ('High')

--Calculate the average number of virtual meetings for each work location and sort the results in descending order
select distinct work_location 
	, round(avg(number_of_virtual_meetings),2) as average_virtual_meetings
from remote_work rw 
group by 1
order by 2 desc

--Identify the top3 regions by the number of employees with the highest rating of social isolation.
select distinct region  
	, count(*)
from remote_work
where social_isolation_rating = 5
group by region 
order by 2 desc
limit 3

--To determine the most frequent stress level, physical activity, sleep quality, and mental health condition among different work locations.
select distinct work_location
	, mode() within group(ORDER BY stress_level) as stress_level
	, mode() within group(ORDER BY physical_activity) as physical_activity
	, mode() within group(ORDER BY sleep_quality) as sleep_quality
	, mode() within group(ORDER BY mental_health_condition) as mental_health_condition
from remote_work
group by 1

--Identify the three industries with the largest number of remote workers
select industry 
	, count(*) as remote_workers
from remote_work 
where work_location like ('Remote')
group by industry 
order by 2 desc
limit 3

--Identify the three job role with the highest number of employees who reported having no mental health problems.
select job_role
	, count(*) 
from remote_work
where mental_health_condition like ('None') 
group by job_role
order by 2 desc
limit 3

--Calculating the percentage of employees in each work location (onsite, remote, hybrid) has a high level of stress
select 'Onsite' as work_location
	, round(count(case when stress_level = 'High' then 1 end)*100.0/count(*),2) as percent_High_stress
from remote_work 
where work_location = 'Onsite'
union 
select 'Remote' as work_location
	, round(count(case when stress_level = 'High' then 1 end)*100.0/count(*),2) as percent_High_stress
from remote_work 
where work_location = 'Remote'
union
select 'Hybrid' as work_location
	, round(count(case when stress_level = 'High' then 1 end)*100.0/count(*),2) as percent_High_stress
from remote_work 
where work_location = 'Hybrid'

--Divide the data into age groups and determine the average level of social isolation for each age group.
select case when age between 22 and 32 then '22-32'
	when age between 33 and 44 then '33-44'
	else '45+' end as age_group
	, round(avg(social_isolation_rating),2) as average_social_isolation
from remote_work
group by age_group





