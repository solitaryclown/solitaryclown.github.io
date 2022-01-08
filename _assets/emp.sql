CREATE TABLE emp (
	empno INT PRIMARY KEY,
	ename VARCHAR (10),
	job VARCHAR (9),
	mgr INT,
	hiredate date,
	sal DECIMAL (7, 2),
	comm DECIMAL (7, 2),
	deptno INT
);



insert into emp values( 7839, 'KING', 'PRESIDENT', null, str_to_date('17-11-1981','%d-%m-%Y'), 5000, null, 10 );
insert into emp values( 7698, 'BLAKE', 'MANAGER', 7839, str_to_date('1-5-1981','%d-%m-%Y'), 2850, null, 30 );
insert into emp values( 7782, 'CLARK', 'MANAGER', 7839, str_to_date('9-6-1981','%d-%m-%Y'), 2450, null, 10 );
insert into emp values( 7566, 'JONES', 'MANAGER', 7839, str_to_date('2-4-1981','%d-%m-%Y'), 2975, null, 20 );
insert into emp values( 7788, 'SCOTT', 'ANALYST', 7566, str_to_date('13-07-1987','%d-%m-%Y'), 3000, null, 20 );
insert into emp values( 7902, 'FORD', 'ANALYST', 7566, str_to_date('3-12-1981','%d-%m-%Y'), 3000, null, 20 );
insert into emp values( 7369, 'SMITH', 'CLERK', 7902, str_to_date('17-12-1980','%d-%m-%Y'), 800, null, 20 );
insert into emp values( 7499, 'ALLEN', 'SALESMAN', 7698, str_to_date('20-2-1981','%d-%m-%Y'), 1600, 300, 30 );
insert into emp values( 7521, 'WARD', 'SALESMAN', 7698, str_to_date('22-2-1981','%d-%m-%Y'), 1250, 500, 30 );
insert into emp values( 7654, 'MARTIN', 'SALESMAN', 7698, str_to_date('28-9-1981','%d-%m-%Y'), 1250, 1400, 30 );
insert into emp values( 7844, 'TURNER', 'SALESMAN', 7698, str_to_date('8-9-1981','%d-%m-%Y'), 1500, 0, 30 );
insert into emp values( 7876, 'ADAMS', 'CLERK', 7788, str_to_date('13-07-1987', '%d-%m-%Y') , 1100, null, 20 );
insert into emp values( 7900, 'JAMES', 'CLERK', 7698, str_to_date('3-12-1981','%d-%m-%Y'), 950, null, 30 );
insert into emp values( 7934, 'MILLER', 'CLERK', 7782, str_to_date('23-1-1982','%d-%m-%Y'), 1300, null, 10 );



