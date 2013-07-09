%
% Understanding Relational Database Query Languages, S. W. Dietrich, Prentice Hall, 2001.
%
% -------------------------------------------------------------------------------------------------------------------------------
%                 		SQL
% -------------------------------------------------------------------------------------------------------------------------------
%                        EMPLOYEE TRAINING Enterprise
%
%  employee(eID, eLast, eFirst, eTitle, eSalary)
%       primary key (eID)
%  technologyArea(aID, aTitle, aURL, aLeadID)
%       primary key (aID)
%       foreign key (aLeadID) references employee(eID)
%  trainingCourse(cID, cTitle, cHours, areaID)
%       primary key (cID)
%       foreign key (areaID) references technologyArea(aID)
%  takes(eID, cID, tYear, tMonth, tDay)
%       primary key (eID, cID)
%       foreign key (eID) references employee(eID)
%       foreign key (cID) references course(cID)
%
%--------------------------------------------------------------------------------------------------------------------------------
%  Revised: November 2002 - WinRBDI 3.1 now supports joined tables in the from clause
%  Revised/Added the following queries: g2, h1, moreThanOneTechArea, q4A, q1C, q2B
%--------------------------------------------------------------------------------------------------------------------------------
%
% SQL: Fundamental EMPLOYEE TRAINING Queries

qSelection := 
    select * 
    from employee E 
    where E.eSalary > 100000; 

qProjection :=
    select distinct E.eLast, E.eFirst, E.eTitle 
    from employee E;

qUnion :=
    select E.eID from employee E where E.eTitle='Manager' 		
    union 										
    select E.eID from employee E where E.eTitle='Coach';

% Alternative for qUnion: using or in where condition
qUnionA :=
    select E.eID 
    from employee E 
    where E.eTitle='Manager' or E.eTitle='Coach';

qDifference :=
    select E.eID from employee E where E.eTitle='Manager' 		
   except
    select T.eID from takes T;

qProduct :=
    select E.eID, C.cID from employee E, trainingCourse C;


% SQL: Additional EMPLOYEE TRAINING Queries

qIntersection :=
    select E.eID from employee E where E.eTitle='Manager'
    intersect
    select T.eID from takes T;

qJoin :=
    select *
    from employee E, technologyArea A
    where E.eID=A.aLeadID;

qNaturalJoin :=
    select distinct C.cTitle, T.tYear, T.tMonth, T.tDay
    from trainingCourse C, takes T
    where C.cID=T.cID;

% SQL: Exists Queries

qDifferenceA :=
   select    E.eID   
   from      employee E   
   where     E.eTitle='Manager' and not exists  
       (select    *   
        from      takes T   
        where     T.eID=E.eID);

qIntersectionA :=
select    E.eID   
   from      employee E   
   where     E.eTitle='Manager' and exists  
       (select    *   
        from      takes T   
        where     T.eID=E.eID);

% Division: see query Q6 below (see also the separate ABSTRACT DIVISION enterprise)

% SQL: Safety Example

leads :=
    select E.eID 
    from  employee E
    where exists 
	(select *
	 from technologyArea A 
	 where A.aLeadID=E.eID);

% Alternative for leads: renaming attributes
leadsA(eID) :=
    select aLeadID
    from technologyArea;

qSafety :=
   select    E.eID   
   from      employee E   
   where     not exists  
       (select    *   
        from      leads L   
        where     L.eID=E.eID);

% SQL: Example EMPLOYEE TRAINING Queries

% Q1: What training courses are offered in the `Database' technology area?
%     (cID, cTitle, cHours)

dbCourse := 
   select    C.cID, C.cTitle, C.cHours  
   from      trainingCourse C  
   where     exists 
      (select    *  
       from      technologyArea A  
       where     A.aID = C.areaID and A.aTitle = 'Database'); 

% Q2: Which employees have taken a training course offered in the 
%     'Database' technology area?
%     (eID, eLast, eFirst, eTitle)

dbEmployee :=
   select    E.eID, E.eLast, E.eFirst, E.eTitle  
   from      employee E   
   where     exists  
      (select    *   
       from      takes T, dbCourse D   
       where     T.eID=E.eID and T.cID=D.cID);

% Q3: Which employees have not taken any training courses?
%     (eID, eLast, eFirst, eTitle)

q3 :=
   select    E.eID, E.eLast, E.eFirst, E.eTitle  
   from      employee E   
   where     not exists  
      (select    *   
       from      takes T   
       where     T.eID=E.eID);

% Q4: Which employees took courses in more than one technology area?  
%     (eID, eLast, eFirst, eTitle)

q4 :=
   select    E.eID, E.eLast, E.eFirst, E.eTitle  
   from      employee E   
   where     exists  
      (select    *   
       from      takes T1, takes T2, trainingCourse C1, trainingCourse C2   
       where     T1.eID=E.eID and T2.eID=E.eID and   
                 T1.cID=C1.cID and T2.cID=C2.cID and   
                 C1.areaID  <>  C2.areaID); 

% Q5: Which employees have the minimum salary?
%     (eID, eLast, eFirst, eTitle, eSalary)

q5 :=
   select    E.eID, E.eLast, E.eFirst, E.eTitle  
   from      employee E   
   where     not exists  
      (select    *   
       from      employee S   
       where     S.eSalary  <  E.eSalary);

% Q6: Which employees took all of the training courses offered 
%     in the `Database' technology area?  
%     (eID, eLast, eFirst, eTitle)

q6 :=
   select    E.eID, E.eLast, E.eFirst, E.eTitle  
   from      employee E   
   where    exists (select * from dbEmployee B where B.eID=E.eID) and
      not exists  
      (select    *   
       from      dbCourse D   
       where     not exists   
                 (select    *   
                  from      takes T   
                  where     T.eID=E.eID and T.cID=D.cID));

%---------------------------------  Additional Features of the Query Language -------------------------------------------------------

% Sorting

o1 :=
   select      E.eLast, E.eTitle, E.eSalary 
   from        employee E
   order by    E.eLast;

% Aggregation

a1(minSalary, maxSalary, avgSalary, sumSalary, countEmps) :=
   select      min(E.eSalary), max(E.eSalary), avg(E.eSalary), 
  	       sum(E.eSalary), count(*) 
   from        employee E;

a2(numEmpsTakenDB) :=
   select      count(distinct T.eID) 
   from        dbCourse D, takes T 
   where       D.cID = T.cID; 

% Grouping

g1(eTitle, minSalary, maxSalary, avgSalary) :=
   select      E.eTitle, min(E.eSalary), max(E.eSalary), avg(E.eSalary) 
   from        employee E 
   group by    E.eTitle;

% WinRDBI 3.1 now supports the SQL syntax for selective column renaming
g2 :=
   select      A.aID, A.aTitle, count(distinct T.eID) as numEmps
   from        technologyArea A, trainingCourse C, takes T 
   where       A.aID = C.areaID and 
               C.cID = T.cID 
   group by    A.aID, A.aTitle;

% Having

% Revised for WinRDBI 3.1
h1 := 
  select      A.aID, A.aTitle, count(distinct T.eID) as numEmps
   from        technologyArea A, trainingCourse C, takes T 
   where       A.aID = C.areaID and 
               C.cID = T.cID 
   group by    A.aID, A.aTitle
   having numEmps >= 4
   order by numEmps desc;

numEmpsTakenArea :=
   select      *
   from        g2;

h2 :=
   select      * 
   from        numEmpsTakenArea 
   where       numEmps  >=  4 
   order by    numEmps desc;

% Revised for WinRDBI 3.1: moreThanOneTechArea and q4A
moreThanOneTechArea :=
   select     T.eID, count(distinct areaID) as numAreas
   from        takes T, trainingCourse C
   where     T.cID = C.cID
   group by T.eID
   having     numAreas > 1;

q4A := 
   select   E.eID, E.eLast, E.eFirst, E.eTitle
   from      employee E
   where   exists
                 (select     *
                  from        moreThanOneTechArea M
                  where      M.eID = E.eID);

% Nested subqueries

% Alternative for q1: nested subqueries equality comparison
q1A := 
   select    C.cID, C.cTitle, C.cHours 
   from      trainingCourse C 
   where     C.areaID = 
      (select    A.aID 
       from      technologyArea A 
       where     A.aTitle = 'Database'); 

% Alternative for q5: nested subqueries equality comparison
% Since WinRDBI does not support aggregation in nested subqueries,
% this query is broken down into two queries
q5Ai(minSalary) := 
   select    min(E.eSalary) 
   from      employee E; 

q5Aii :=
   select    E.eID, E.eLast, E.eFirst, E.eTitle, E.eSalary
   from      employee E, q5Ai Q
   where     E.eSalary = Q.minSalary;

% Alternative for q2: nested subqueries set membership comparison
q2A :=
   select    E.eID, E.eLast, E.eFirst, E.eTitle
   from      employee E 
   where     E.eID in
      (select    T.eID 
       from      takes T, dbCourse D 
       where     T.cID=D.cID); 

% Alternative for q3: nested subqueries set membership comparison
q3A :=
   select    E.eID, E.eLast, E.eFirst, E.eTitle
   from      employee E 
   where     E.eID not in
      (select    T.eID 
       from      takes T); 

% Joined Tables

% WinRDBI 3.1  SQL now supports the joined table syntax in the from clause

% Alternative for q1 (Q1B): join specified in where condition
q1B :=
    select 	C.cID, C.cTitle, C.cHours 
    from   	trainingCourse C, technologyArea A 
    where  	C.areaID = A.aID and A.aTitle = 'Database'; 

q1C :=
    select 	C.cID, C.cTitle, C.cHours 
    from   	(trainingCourse C join technologyArea A on areaID = aID)
    where  	A.aTitle = 'Database'; 

q2B := 
   select               distinct E.eID, E.eLast, E.eFirst, E.eTitle
   from                 (employee E natural join (takes T natural join dbCourse D));

% Query Optimization

% q2 query definition: nested correlated subquery
% Commented out here since it appears earlier as the definition of dbEmployee
%q2 :=
%    select    E.eID, E.eLast, E.eFirst, E.eTitle  
%    from      employee E   
%    where     exists  
%       (select    *   
%        from      takes T, dbCourse D   
%        where     T.eID=E.eID and T.cID=D.cID);

% Alternative for q2 (Q2A): nested uncorrelated query
% Commented out here since it appears earlier as an example of a nested subquery using set membership comparison
%q2A :=
%    select 	E.eID, E.eLast, E.eFirst, E.eTitle
%    from   	employee E 
%    where  	E.eID in
%	 (select 	T.eID 
%   	 from   	takes T, dbCourse D 
%   	 where  	T.cID=D.cID); 

% Alternative for q2 (Q2B): commented out here since it is already shown under joined tables 
%q2B := 
%  select               distinct E.eID, E.eLast, E.eFirst, E.eTitle
%   from                 (employee E natural join (takes T natural join dbCourse D));

% Alternative for q2 (Q2C): join condition in the where clause
q2C :=
    select 	distinct E.eID, E.eLast, E.eFirst, E.eTitle
    from   	employee E, takes T, dbCourse D 
    where  	E.eID = T.eID and T.cID=D.cID; 

%-----------------------------------------End EMPLOYEE TRAINING Enterprise--------------------------------------

