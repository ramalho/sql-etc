%
% Understanding Relational Database Query Languages, S. W. Dietrich, Prentice Hall, 2001.
%
% -----------------------------------------------------------------------
%	          SQL
% -----------------------------------------------------------------------
%                        New Home Enterprise
%
%  homebuilder(hID, hName, hStreet, hCity, hZip, hPhone)
%       primary key (hID)
%  model(hID, mID, mName, sqft, story)
%       primary key (hID, mID)
%       foreign key (hID) references homebuilder(hID)
%  subdivision(sName, sCity, sZip)
%       primary key (sName)
%  offered(sName, hID, mID, price)
%       primary key (sName, hID, mID)
%       foreign key (sName) references subdivision(sName)
%       foreign key (hID, mID) references model(hID, mID)
%  lot(sName, lotNum, lStAddr, lSize, lPremium)
%       primary key (sName, lotNum)
%       foreign key (sName) references subdivision(sName)
%  sold(sName, lotNum, hID, mID, status)
%       primary key (sName, lotNum)
%       foreign key (sName, lotNum) references lot(sName,lotNum)
%       foreign key (hID, mID) references model(hID, mID)
%
%------------------------------------------------------------------------
% Q2.1	Are there subdivisions that only offer single-story homes?
%	(sName, sCity, sZip)

subdivisionsOfferSingle :=
select 	distinct O.sName 
from 	offered O, model M
where 	O.hID=M.hID and O.mID=M.mID and	M.story = '1';
 
subdivisionsOfferOther :=
select 	distinct O.sName 
from 	offered O, model M
where 	O.hID=M.hID and O.mID=M.mID and	M.story <> '1';

sql1 :=
select	*
from	subdivision S
where	exists
	(select *
	 from 	subdivisionsOfferSingle O
	 where 	S.sName=O.sName) 
	and
	not exists 
	(select *
	 from 	subdivisionsOfferOther D
	 where 	S.sName=D.sName);

% -----------------------------------------------------------------------
% Q2.2	List all the homebuilders who offer single-story models 
%	with at least 2000 square feet in subdivisions located in "Tempe". 
%	(hName, hPhone)

sql2 :=
select	H.hName, H.hPhone
from	homebuilder H, model M, offered O, subdivision S
where	H.hID=M.hID and M.story='1' and M.sqft > 2000 and
	M.hID=O.hID and M.mID=O.mID and
	O.sName=S.sName and S.sCity='Tempe';

%------------------------------------------------------------------------
% Q2.3 	Which lots in the "Terraces" subdivision are available i.e. not sold? 
%	(lotNum, lStAddr, lSize, lPremium)

sql3 :=
select 	L.lotNum, L.lStAddr, L.lSize, L.lPremium
from 	lot L
where	L.sName='Terraces' and
	not exists 
	(select	*
	 from	sold S
	 where	S.sName=L.sName and S.lotNum=L.lotNum);

%------------------------------------------------------------------------
% Q2.4	Which model(s) are not currently offered in any subdivision? 
%	(hName, mName)

sql4 :=
select	H.hName, M.mName
from	homebuilder H, model M
where	H.hID = M.hID and
	not exists
	(select *
	 from	offered O
	 where	M.hID=O.hID and M.mID=O.mID);

%------------------------------------------------------------------------
% Q2.5	Which subdivisions offer models from more than one homebuilder?
%	(sName, sCity, sZip)

countBuilders(sName, numberBuilders) :=
select 	sName, count(distinct hID)
from	offered
group by sName;

sql5 :=
select	*
from	subdivision S
where	exists
	(select *
	 from	countBuilders C
	 where	C.sName= S.sName and C.numberBuilders > 1);

%------------------------------------------------------------------------
% Q2.6	Which models are offered in only one subdivision? 
%	(hName, mName)

modelsOnlyOneSubdivision :=
select 	 hID, mID, count(*)
from	 offered O
group by hID, mID
having	 count(*) = 1;

sql6 :=
select	H.hName, M.mName
from	homebuilder H, model M, modelsOnlyOneSubdivision S
where	H.hID = M.hID and M.hID=S.hID and M.mID=S.mID;

%------------------------------------------------------------------------
% Q2.7	Which model(s) offered in the "Foothills" subdivision 
%	has the maximum square footage? 
%	(hName, mName, sqft)

foothillsModels :=
select 	M.hID, M.mID, M.sqft
from 	model M, offered O
where 	M.hID=O.hID and M.mID=O.mID and
      	O.sName = 'Foothills';

maxSqftFoothills(maxsqft) :=
select 	max(sqft)
from 	foothillsModels;

maxSqftFoothillsModels :=    
select 	F.hID, F.mID, F.sqft
from 	foothillsModels F, maxSqftFoothills M
where 	F.sqft=M.maxsqft;

sql7 :=    
select 	H.hName, M.mName, S.sqft
from  	homebuilder H, model M, maxSqftFoothillsModels S
where 	H.hID=S.hID and M.hID=S.hID and M.mID=S.mID;

%------------------------------------------------------------------------
% Q2.8	Which subdivision offers all the models by the homebuilder "Homer"? 
%	(sName, sCity, sZip)

homerModels  := 
select 	M.hID, M.mID
from 	homebuilder H, model M
where 	H.hName='Homer' and H.hID=M.hID;

offersHomerModels :=
select 	S.sName
from 	subdivision S
where 	exists
 	(select * 
	  from	offered O, homerModels M
	  where	S.sName=O.sName and O.hID=M.hID) ;

sql8           := 
select 	S.sName, S.sCity, S.sZip
from 	subdivision S, offersHomerModels O
where	S.sName=O.sName and
	 not exists
     	     (select *
      	      from homerModels H
      	      where not exists
          	        (select *
            	         from offered F
            	         where F.sName=S.sName and F.hID=H.hID and F.mID=H.mID));

%------------------------------------------------------------------------
% Q2.9 	For each subdivision, find the number of models offered and 
%	the average, minimum and maximum price of the models offered at that subdivision. 
%	Display the result in descending order on the average price of a home.
%	(sName, sCity, numberOfModels, avgPrice, minPrice, maxPrice)

sql9(sName, sCity, numberOfModels, avgPrice, minPrice, maxPrice) :=
select 	 S.sName, S.sCity, count(*), avg(O.price), min(O.price), max(O.price)
from  	 offered O, subdivision S
where 	 O.sName=S.sName
group by S.sName, S.sCity
order by 4 desc;

%------------------------------------------------------------------------
% Q2.10	For each subdivision, find the total of lot premiums for lots that are available. 
%	Display the result in ascending order on the total of lot premiums. 
%	(sName, sCity, totalLotPremium)

sql10(sName, sCity, totalLotPremium) :=
select 	S.sName, S.sCity, sum(L.lPremium)
from 	subdivision S, lot L
where 	S.sName=L.sName and
      	not exists 
	(select	*
	 from	sold D
	 where	D.sName=L.sName and D.lotNum=L.lotNum)	
group by S.sName, S.sCity
order by 3;

%---------------------------End New Home Enterprise-------------------------------

