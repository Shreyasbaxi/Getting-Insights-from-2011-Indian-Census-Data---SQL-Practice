select * from census..data1;
Select * from census..data2;
-- number of rows in our dataset 
select count(*) from census..data1
select count(*) from census..data2

Alter Table census..data1
Alter Column 
Sex_Ratio FLoat;

-- dataset for jharkhand and Bihar
select * from census..data1 where State in ('Jharkhand','Bihar')

--Total population of India
select sum(Population) As Total_Population from census..data2 

--Avg Population

select state, Avg(Growth)*100 as AverageGrowth from census..data1 group by state;

-- Avg Sex Raio
select state, Avg(Sex_Ratio) as Avg_Sex_ratio from census..data1 group by state order by Avg_Sex_ratio desc;

--Avg Literacy Rate

select state, round(Avg(literacy),2) as Avg_Literacy from census..data1 
group by state having round(Avg(literacy),2)> 90 order by  Avg_Literacy desc ;

--  3 states displaying highest growth rate 

select Top 3 state, avg(Growth)*100 as AverageGrowth from census..data1 
group by state order by AverageGrowth Desc; 

--  3 states having lowest sex ratio 

select state, avg(Sex_Ratio) as Avg_Sex_Ratio from census..data1 
group by state order by Avg_Sex_Ratio Desc; 



-- Sex Ratio as per districts

select Top 3 District, Sex_Ratio from census..data1 order by Sex_Ratio Asc;

--Top and Bottom 3 states in Literacy Rate ( Creating Temp Table and Inserting Data into it)
drop table if exists #topstates
create table #topstates
(States nvarchar (255),
 LitRate float
 )
 insert into #topstates
  select state, round(avg(Literacy),0) as avg_literacy from census..data1
  group by state order by avg_literacy desc;

  select top 3 *  from #topstates order by LitRate desc;


drop table if exists #bottomstates
create table #bottomstates
(States nvarchar (255),
LitRate float
)
insert into #bottomstates
 select state, round(avg(Literacy),0) as avg_literacy from census..data1
  group by state order by avg_literacy desc;
select Top 3 * from #bottomstates order by LitRate Asc;

-- Union Operators
  select * from ( select top 3 *  from #topstates order by LitRate desc) a

  union

  select * from (select Top 3 * from #bottomstates order by LitRate Asc) b;

--- States starting with Letter a and m 
select distinct State from census..data1 where lower(state) like 'a%' and lower(state) like '%m';

--- joining both tables

select a.District,a.state,a.Sex_Ratio/1000 Sex_Ratio,b.population from census..data1 a Inner Join	census..data2 b on a.District = b.District

-- Getting Number of Males and Females
select c.District, c.State, round(c.population/(c.Sex_Ratio+1),0) males, round((c.population*c.Sex_Ratio)/(c.Sex_Ratio+1),0) females from 
(select a.District,a.state, a.Sex_Ratio/1000 Sex_Ratio,b.population from census..data1 a Inner Join census..data2 b on a.District = b.District) c

-- Getting Number of Males and Females grouped by States [ Inner Join and Sub Querying]
select d.state, sum(d.males) Total_Males,sum (d.females) Total_Females from 
(select c.District, c.State, round(c.population/(c.Sex_Ratio+1),0) males, round((c.population*c.Sex_Ratio)/(c.Sex_Ratio+1),0) females from 
(select a.District,a.state, a.Sex_Ratio/1000 Sex_Ratio,b.population from census..data1 a Inner Join census..data2 b on a.District = b.District) c ) d
group by d.State

--- Getting number of Literate and illiterate People in a State and select to 5 states with highest Illeterate population
select top 5 d.state,d.Illiterate_Population, d.Total_Population from
(select e.state, sum(e.Literate_Population)Literate_Population, sum(e.Illiterate_Population)Illiterate_Population,sum(e.population) Total_Population from
(select c.district, c.state, c.population, round( c.literacy_ratio * c.population,0) Literate_Population, round((1-c.Literacy_Ratio)*c.population,0) Illiterate_Population from
(select a.District,a.state, a.Literacy/100 Literacy_Ratio ,b.population from census..data1 a Inner Join census..data2 b on a.District = b.District) c ) e 
group by e.state ) d
order by d.Illiterate_Population Desc

---Window using rank function to get top 3 Districts in each states with Lowest Literacy
select b.* from
(select a.* from 
(select district,state, literacy,rank() over (partition by state order by literacy Desc) rnk from census..data1 ) a
where a.rnk in (1,2,3) ) b
where lower(b.state )like 'm%' and  lower(b.state ) like '%a'
