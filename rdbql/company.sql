%
% Fundamentals of Database Systems, 4th ed., R. Elmasri and S. B. Navathe, Addison Wesley, 2004
%
% Schema (Chapter 5, Figure 5.5, page 136)
%   employee(fname, minit, lname, ssn, bdate, address, sex, salary, superssn, dno)
%        primary key (ssn)
%        foreign key (supersnn) references employee(ssn)
%        foreign key (dno) references department(dnumber)
%   department(dname, dnumber, mgrssn, mgrstartdate)
%        primary key (dnumber)
%	 foreign key (mgrssn) references employee(ssn)
%   dept_locations(dnumber, dlocation)
%        primary key (dnumber,dlocation)
%        foreign key (dnumber) references department(dnumber)
%%%%  NOTE THAT THE TABLE project IS NAMED projects BECAUSE OF THE project RELATIONAL ALGEBRA OPERATOR.
%   projects(pname, pnumber, plocation, dnum)
%        primary key (pnumber)
%        foreign key (dnum) references department(dnumber)
%   works_on(essn, pno, hours)
%        primary key (essn, pno)
%        foreign key (esnn) references employee(ssn)
%        foreign key (pno) references projects(pnumber)
%   dependent(essn, dependent_name, sex, bdate, relationship)
%        primary key (essn, dependent_name)
%        foreign key (esnn) references employee(ssn)
% Instance (Chapter 5, Figure 5.6, page 137)
%   Note there is one additional works_on('123456789',3,15) tuple so that query 3 is non-empty.
% Queries (Chapter 6, Section 6.5, pp 171-173)

% SQL ---------------------------------------------
 
% ----- query 1 -----;
% Retrieve the name and address of all employees who work for the 
% 'Research' department.

sql1 := select fname,lname,address
        from employee, department
        where dname = 'Research' and
              dnumber = dno;

% ----- query 2 -----;
% For every project located in 'Stafford', list the project number, the
% controlling department number, and the department manager's last name,
% address, and birthdate.

sql2 := select pnumber,dnum,lname,address,bdate
        from projects,department,employee
        where dnum = dnumber and
              mgrssn = ssn and
              plocation = 'Stafford';

% ----- query 3 -----;
% Find the names of employees who work on all the projects controlled
% by department number 5.

sql3 := select lname,fname 
        from employee E
        where not exists (select *
                          from projects P
                          where P.dnum = 5 and not exists (select *
                                                           from works_on W
                                                           where W.essn = E.ssn and
                                                           W.pno = P.pnumber));
                                                           

% ----- query 4 -----;
% Make a list of project numbers for projects that involve an employee
% whose last name is 'Smith', either as a worker or as a manager of the
% department that controls the project.

sql4(pnumber) :=
	(select pnumber 
         from   projects, department, employee
         where  dnum = dnumber and
                mgrssn = ssn and
                lname = 'Smith')
        union
        (select pnumber
         from   projects,works_on, employee
         where  pnumber = pno and
                essn = ssn and
                lname = 'Smith');

% ----- query 5 -----;
% List the names of all employees with two or more dependents.

depNum(ssn, depcnt) := select ssn, count(*)
                       from employee,dependent
                       where ssn = essn
                       group by ssn;

sql5 := select lname,fname 
        from   employee e, depNum d
        where  e.ssn = d.ssn and
               depcnt >= 2;

% ----- query 6 -----;
% Retrieve the names of employees who have no dependents.

sql6 := select lname,fname
        from   employee
        where  not exists (select *
                           from dependent
                           where ssn = essn);

% ----- query 7 -----;
% List the names of managers who have at least one dependent.

sql7 := select lname,fname 
        from   employee
        where  exists (select *
                       from   dependent
                       where  ssn = essn) and
               exists (select *
                       from   department
                       where  ssn = mgrssn);


