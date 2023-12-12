IF OBJECT_ID('tempdb..#AllTrips') IS NOT NULL DROP TABLE #AllTrips

-- BUILDING THE TRIP INFO

SELECT  newid() as art_trip_id,
				vessel_id, vessel_name, py,
				trip_date, return_date,
				jdep, jret, hdep, hret,
				1024 as visibility, 1024 as validity, 1024 as instance_source, 
				'BASEPROD' as system_source, getdate() as entered_date,
				'BASEPROD' as entered_by,
				min(LS.landing_site_id) as landing_site_id,
				min(depart_time) as depart_time,
				max(return_time) as return_time,
				min(espece) as espece,
				sum(convert(INT,nbre)) as nbre
				into #alltrips
FROM
(
		-- getting each distinct trip
Select v.vessel_id, v.vessel_name, py, jdep, jret, hdep, hret,
				IIF(jdep is null,null,CAST(CONCAT(
						right(left(jdep,len(jdep)-8),4),'-',  
						right(left(jdep,len(jdep)-13),len(left(jdep,len(jdep)-13))-charindex('/',left(jdep,len(jdep)-13))),'-',  
						left(left(jdep,len(jdep)-13),charindex('/',left(jdep,len(jdep)-13))-1)
						) as date)) as trip_date, 
				IIF(jret is null,null,CAST(CONCAT(
						right(left(jret,len(jret)-8),4),'-',  
						right(left(jret,len(jret)-13),len(left(jret,len(jret)-13))-charindex('/',left(jret,len(jret)-13))),'-',  
						left(left(jret,len(jret)-13),charindex('/',left(jret,len(jret)-13))-1)
						) as date)) as return_date,
				min(IIF(hdep is null,null,CONCAT(left(right(CONCAT('0',left(right(hdep,len(hdep)-charindex(' ',hdep)), len(right(hdep,len(hdep)-charindex(' ',hdep)))-3)),5),2), right(right(CONCAT('0',left(right(hdep,len(hdep)-charindex(' ',hdep)), len(right(hdep,len(hdep)-charindex(' ',hdep)))-3)),5),2)))) as depart_time,
				max(IIF(hret is null,null,CONCAT(left(right(CONCAT('0',left(right(hret,len(hret)-charindex(' ',hret)), len(right(hret,len(hret)-charindex(' ',hret)))-3)),5),2), right(right(CONCAT('0',left(right(hret,len(hret)-charindex(' ',hret)), len(right(hret,len(hret)-charindex(' ',hret)))-3)),5),2)))) as return_time,
				min(base) as base,
				min(espece) as espece,
				sum(convert(decimal(6,2),nbre)) as nbre
		FROM [dbo].[PF_Artisanal_BASEPROD] BP
				INNER JOIN tufman2.art2.vessels V on V.ves_unique_id = BP.py and V.visibility = 1024
		WHERE BP.py is not null and BP.jdep is not null and BP.jret is not null
		GROUP BY v.vessel_id, v.vessel_name, py, jdep, jret, hdep, hret
) tmptrip		
	LEFT JOIN tufman2.art2.landing_sites LS on ls.landing_site_name = tmptrip.Base and LS.visibility=1024
group by tmptrip.vessel_id, tmptrip.vessel_name, tmptrip.py, tmptrip.trip_date, tmptrip.return_date, tmptrip.jdep, tmptrip.jret, tmptrip.hdep, tmptrip.hret

-- select * from #alltrips

-- listing all the trips that are not already in T2
IF OBJECT_ID('dbo._TRIPS_TO_ADD', 'U') IS NOT NULL DROP TABLE dbo._TRIPS_TO_ADD


SELECT BT.*,
				IIF(BT.depart_time is not null or BT.return_time is not null or coalesce(nbre,0)>0, null,
					CASE espece
						when 'arret' then 1
						when 'entretien' then 2
						when 'pan' then 3
						when 'panne' then 3
						when 'repos' then 9 
						when 'sauvetage' then 11
						when 'ar' then 1
						when 'maladie' then 7
						when 'cale' then 15
						when 'arr' then 1 
						when 'vente' then 12
						when 'compet' then 5
						when 'essai' then 6
						when 'route' then 10
						when 'visite' then 13
						when 'activite baleine' then 4
						when 'competition' then 5
						when 'deces' then 7
						when 'arret' then 9
						when 'meteo defavorable' then 8
						when 'vidange' then 6
						else null
					END
				) as non_fishing_trip_reason_id
				
INTO _TRIPS_TO_ADD
from #alltrips BT
	left join tufman2.art2.trips T on T.vessel_id = BT.vessel_id and t.Trip_date < BT.return_date and BT.trip_date < T.return_date and T.visibility=1024
WHERE  T.art_trip_id is null

--select count(*) from #alltrips
--select count(*) from dbo._TRIPS_TO_ADD where  non_fishing_trip_reason_id is null and espece is null and nbre is null
--select year(trip_date), count(*) from dbo._TRIPS_TO_ADD group by year(trip_date)
--select * from dbo._TRIPS_TO_ADD order by non_fishing_trip_reason_id	desc	--, py, trip_date, return_date
--select count(*) from dbo.PF_Artisanal_BASEPROD

-- inserting new trips only in tufman2
BEGIN TRANSACTION

Insert into tufman2.art2.trips (art_trip_id, vessel_id, trip_date, return_date, depart_time, return_time, visibility, validity, instance_source, system_source, 
																entered_date, entered_by, landing_site_id, is_creel, non_fishing_trip_reason_id)
Select art_trip_id, vessel_id, trip_date, return_date, depart_time, return_time, visibility, validity, instance_source, system_source, entered_date, entered_by, landing_site_id, 0, non_fishing_trip_reason_id
from _TRIPS_TO_ADD

-- COMMIT
-- ROLLBACK

/*
-- TRYING TO SEE WHY I HAVE TRIP DUPLICATES in #AllTrips
-- Is this at the vessel definition under T2?
-- Elswhere ?
-- to be checked

Select vessel_id, trip_date, return_date, depart_time, return_time, count(*) as cnt from _TRIPS_TO_ADD group by vessel_id, trip_date, return_date, depart_time, return_time having count(*)>1

select py, jdep, jret, count(*) from dbo.PF_Artisanal_BASEPROD group by py, jdep, jret having count(*)>1

Select count(*) from tufman2.art2.trips

Select T2V.vessel_id, T2v.vessel_name, count(*) 
from tufman2.art2.vessels T2V
inner join 
(Select distinct vessel_id as vessel_id from #alltrips ) tmpvess on tmpvess.vessel_id = T2V.vessel_id
GROUP BY T2V.vessel_id, T2V.Vessel_name
having count(*)>1
-- Select vessel_id, count(*) from dbo._VESSELS_TO_ADD group by vessel_id having count(*)>1

*/


		