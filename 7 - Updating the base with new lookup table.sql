-- 2023-12-14 - changing the BASE according to the 3 PF_Artisanal_BaseConvx tables provided

-- checking trips in error as for dates (years)
Select v.vessel_name, year(trip_date) as Annee_depart, year(return_date) as annee_retour, count(*) 
from tufman2.art2.trips T
	inner join tufman2.art2.vessels V on V.vessel_id = T.vessel_id and V.visibility=1024
where T.visibility = 1024 and year(return_date) - year(trip_date) > 1
group by v.vessel_name, year(trip_date), year(return_date) 
order by 1

-- checking that the new bases are already in T2
select bc1.bases_CORRIGEES
from dbo.PF_Artisanal_BaseConv1 BC1
	Left join tufman2.art2.landing_sites LS on ls.landing_site_name = bc1.bases_CORRIGEES
where ls.landing_site_name is null

-- Checking the new landing site value from conversion table 1
select t.landing_site_id as landing_site_id_old, bc1.bases_BASEPROD, bc1.bases_CORRIGEES, ls2.landing_site_name, ls2.landing_site_id
from tufman2.art2.trips T
	inner join tufman2.art2.landing_sites LS on ls.landing_site_ID = t.landing_site_id
	inner join dbo.PF_Artisanal_BaseConv1 BC1 on bc1.bases_BASEPROD = LS.landing_site_name
	inner join tufman2.art2.landing_sites LS2 on ls2.landing_site_name = bc1.bases_CORRIGEES

-- UPDATE OF LANDING SITES in TRIPS - BConv1
begin TRANSACTION
update T
set t.landing_site_id = ls2.landing_site_id
from tufman2.art2.trips T
	inner join tufman2.art2.landing_sites LS on ls.landing_site_ID = t.landing_site_id
	inner join dbo.PF_Artisanal_BaseConv1 BC1 on bc1.bases_BASEPROD = LS.landing_site_name
	inner join tufman2.art2.landing_sites LS2 on ls2.landing_site_name = bc1.bases_CORRIGEES

-- commit
-- rollback

-- Checking the new landing site value from conversion table 2
select v.vessel_name, t.landing_site_id as landing_site_id_old, BC.bases_BASEPROD, BC.bases_CORRIGEES, ls2.landing_site_name, ls2.landing_site_id
from tufman2.art2.trips T
	inner join tufman2.art2.vessels V on t.vessel_id = V.vessel_id
	inner join tufman2.art2.landing_sites LS on ls.landing_site_ID = t.landing_site_id
	inner join dbo.PF_Artisanal_BaseConv2 BC on BC.bases_BASEPROD = LS.landing_site_name and BC.py = V.vessel_name
	inner join tufman2.art2.landing_sites LS2 on ls2.landing_site_name = BC.bases_CORRIGEES

-- UPDATE OF LANDING SITES in TRIPS - BConv2
begin TRANSACTION
update T
set t.landing_site_id = ls2.landing_site_id
from tufman2.art2.trips T
	inner join tufman2.art2.vessels V on t.vessel_id = V.vessel_id
	inner join tufman2.art2.landing_sites LS on ls.landing_site_ID = t.landing_site_id
	inner join dbo.PF_Artisanal_BaseConv2 BC on BC.bases_BASEPROD = LS.landing_site_name and BC.py = V.vessel_name
	inner join tufman2.art2.landing_sites LS2 on ls2.landing_site_name = BC.bases_CORRIGEES

-- commit
-- rollback

-- checking that the new BC3 bases are already in T2
select bc.bases_CORRIGEES
from dbo.PF_Artisanal_BaseConv3 BC
	Left join tufman2.art2.landing_sites LS on ls.landing_site_name = bc.bases_CORRIGEES
where ls.landing_site_name is null

-- UPDATE OF LANDING SITES in TRIPS - BConv3
begin TRANSACTION
update T
set t.landing_site_id = ls2.landing_site_id
from tufman2.art2.trips T
	inner join tufman2.art2.vessels V on t.vessel_id = V.vessel_id
	inner join tufman2.art2.landing_sites LS on ls.landing_site_ID = t.landing_site_id
	inner join dbo.PF_Artisanal_BaseConv3 BC on BC.bases_BASEPROD = LS.landing_site_name and BC.py = V.vessel_name
	inner join tufman2.art2.landing_sites LS2 on ls2.landing_site_name = BC.bases_CORRIGEES
		
-- commit
-- rollback

-- listing all landing_sites that are unsused in DATABASE
select LS.landing_site_id, LS.landing_site_name
From tufman2.art2.landing_sites LS 
	left join tufman2.art2.trips T on LS.landing_site_id = T.landing_site_id and T.visibility=1024
where ls.visibility = 1024 and T.art_trip_id is null
order by 2

-- DELETING THE UNSUSED LANDING_SITES
BEGIN TRANSACTION
delete from tufman2.art2.landing_sites
where landing_site_id IN	
	(select LS.landing_site_id
		From tufman2.art2.landing_sites LS 
			left join tufman2.art2.trips T on LS.landing_site_id = T.landing_site_id and T.visibility=1024
		where ls.visibility = 1024 and T.art_trip_id is null
	)
and visibility = 1024

-- COMMIT
-- rollback 