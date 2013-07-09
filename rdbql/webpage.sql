%
% Understanding Relational Database Query Languages, S. W. Dietrich, Prentice Hall, 2001.
%
% -------------------------------------------------------------------------------------------------------------------------------
%	        SQL
% -------------------------------------------------------------------------------------------------------------------------------
%                        Web Page Enterprise
%
%  webpage (webID, webTitle, url, base, hits)
%       primary key (webID)
%  httpLink (sourceWebID, targetWebID)
%       primary key (sourceWebID, targetWebID)
%       foreign key (sourceWebID) references webpage(webID)
%       foreign key (targetWebID) references webpage(webID)
%  graphic (gID, gName, gType, gLocation)
%       primary key (gID)
%  display (webID, gID)
%       primary key (webID, gID)
%       foreign key (webID) references webpage(webID)
%       foreign key (gID) references graphic(gID)
%  courseware (cID, cDescription, ftpLocation, category)
%       primary key (cID)
%  ftpLink (webID, cID)
%       primary key (webID, cID)
%       foreign key (webID) references webpage(webID)
%       foreign key (cID) references courseware(cID)
%
%--------------------------------------------------------------------------------------------------------------------------------
% Q1.1	Which pages contain (ftp links to) the class notes?
% 	(webID, webTitle, url, base)

sql1 :=
select 	distinct W.webID, W.webTitle, W.url, W.base 
from 	courseware C, ftpLink F, webpage W
where 	C.category = 'N' and
	F.cID = C.cID and W.webID = F.webID;

% -----------------------------------------------------------------------
% Q1.2	Which pages display graphics having the name 'asulogo'?
%	(webID, webTitle, url, base)

sql2 :=
select 	distinct W.webID, W.webTitle, W.url, W.base
from 	graphic G, display D, webpage W 
where 	G.gName = 'asulogo' and
	D.gID = G.gID and W.webID = D.webID;

%------------------------------------------------------------------------
% Q1.3 	Which pages do not display any graphics?
%	(webID, webTitle, url, base)

sql3 :=
select 	W.webID, W.webTitle, W.url, W.base 
from 	webpage W 
where 	W.webID not in (select webID from display);

%------------------------------------------------------------------------
% Q1.4	Which pages use 'gif' graphics but not 'jpg' graphics?
%	(webID, webTitle, url, base)


gifWebIDs := 
select 	distinct D.webID
from 	display D
where exists
	(select *
	 from graphic G 
	 where G.gType = 'gif' and G.gID = D.gID) ;

jpgWebIDs := 
select 	distinct D.webID
from 	display D
where 	exists
	 (select *
	  from graphic G 
	  where G.gType = 'jpg' and G.gID = D.gID) ;

sql4 :=
	select W.webID, W.webTitle, W.url, W.base 
	from webpage W 
	where exists (select * from gifWebIDs G where G.webID = W.webID) and
	  not exists (select * from jpgWebIDs J where J.webID = W.webID);

%------------------------------------------------------------------------
% Q1.5	Which pages contain more than one (ftp) link to courseware?
%	(webID, webTitle, url, base, hits)

pagesWithMoreThanOneLink(webID, cnt) := 
select 	 webID, count(*)
from 	 ftpLink
group by webID
having 	 count(*) > 1; 

sql5 := 
select 	 W.webID, W.webTitle, W.url, W.base
from 	 webpage W, pagesWithMoreThanOneLink P
where 	 W.webID = P.webID
order by W.webID asc;

%------------------------------------------------------------------------
% Q1.6	Which pages contain only one (http) link to another web page?
%	(webID, webTitle, url, base)	

pagesWithOneLink (webID, cnt) := 
select 	 sourceWebID, count(*)
from 	 httpLink
group by sourceWebID
having   count(*) = 1; 

sql6 := 
select 	 W.webID, W.webTitle, W.url, W.base
from 	 webpage W,pagesWithOneLink P
where 	 W.webID = P.webID
order by W.webID asc;
		
%------------------------------------------------------------------------
% Q1.7	Which pages have the most hits?
%	(webID, webTitle, url, base, hits)

mostHits(maxhits) :=
select	max(hits)
from 	webpage;

sql7 := 
select 	W.webID, W.webTitle, W.url, W.base, W.hits 
from 	webpage W, mostHits M
where 	W.hits = M.maxhits;


%------------------------------------------------------------------------
% Q1.8	Which pages contain (ftp) links to all courseware in the publications category?
%	(webID, webTitle, url, base)

pubCIDs :=
select  *
from    courseware C
where C.category='P';

sql8 := 
select 	W.webID, W.webTitle, W.url, W.base
from 	webpage W
where 	exists
	(select * from pubCIDs P, ftpLink F where W.webID = F.webID and F.cID = P.cID) and
	not exists 
	  (select *
	   from pubCIDs C
	   where not exists
		(select *
		 from ftpLink L
		 where L.webID = W.webID and L.cID = C.cID));

%------------------------------------------------------------------------
% Q1.9  	For each webpage and graphic type, give the number of graphics 
%       	of that type displayed on that page. Display your results in 
%       	ascending order on webID, and within that, in ascending order 
%       	on graphic type (gType).
%	(webID, webTitle, url, base, gType, count)
 
gTypeAndCount (webID, gType, cnt) := 
	select D.webID, G.gType, count(*)
	from display D, graphic G
	where D.gID = G.gID
	group by D.webID, G.gType;

sql9 := 
select 	 W.webID, W.webTitle, W.url, W.base, G.gType, G.cnt
from 	 webpage W, gTypeAndCount G
where 	 W.webID = G.webID
order by W.webID, G.gType;


%------------------------------------------------------------------------
% Q1.10	For each group of pages belonging to a base, 
%	give the average number of hits, the minimum number of hits in that group, 
%	the maximum number of hits in that group and the sum of hits for that group. 
%	Display your results in descending order on average number of hits.
%	(webID, webTitle, url, avgHits, minHits, maxHits, sumHits)

aggregates (base, avgHits, minHits, maxHits, sumHits) := 
select 	 base, avg (hits), min (hits), max (hits), sum (hits)
from 	 webpage
group by base;

sql10 := 
select 	 W.webID, W.webTitle, W.url, A.avgHits, A.minHits, A.maxHits, A.sumHits
from 	 webpage W, aggregates A	
where 	 W.webID = A.base
order by A.avgHits desc;

%-----------------------------End Web Page Enterprise------------------------------


