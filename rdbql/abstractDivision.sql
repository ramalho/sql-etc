%
% Understanding Relational Database Query Languages, S. W. Dietrich, Prentice Hall, 2001.
%
%---------------------------------------------------------------------------------------------------------------------------
%	SQL
%---------------------------------------------------------------------------------------------------------------------------
%  Abstract Division Example
%
%  abTable(a,b)
%       primary key (a, b)
%  bTable(b)
%       primary key (b)
%---------------------------------------------------------------------------------------------------------------------------

existentialDivision :=
   select    distinct T.a  
   from      abTable T   
   where    not exists  
      (select    * 	    				
       from      bTable B   
       where     not exists 	  
                 (select    * 			
                  from      abTable AB   
                  where     AB.a=T.a and AB.b=B.b));
