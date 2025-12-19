-- MS SQL Server-Window Function

-- Hiba Tur Rehman
-- SQL I
-- 77
-- Jun 11, 2022
-- /* Write your T-SQL query statement below */

-- with result as
--  (
-- select d.name as "Department",
-- e.name as "Employee", salary, 
-- dense_rank() over(partition by departmentId
--                                  order by salary desc) RANK
-- from Employee e
-- join Department d
-- on e.departmentId = d.id
-- )
--  select Department, Employee, salary from result where RANK=1;