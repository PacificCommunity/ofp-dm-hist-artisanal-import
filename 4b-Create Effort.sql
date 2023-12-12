

IF OBJECT_ID('dbo._EFFORT_TO_ADD', 'U') IS NOT NULL DROP TABLE dbo._EFFORT_TO_ADD

SELECT  T.art_trip_id, BP.py, BP.base, BP.jdep, BP.jret, BP.hdep, BP.Hret, art_area_id, fish_method_id, 
				max(fad_register_id) as fad_register_id,
				max(IIF(charindex('dcp',BP.rem)>0 or charindex('dcp',BP.detail)>0 or charindex('dcp',BP.typ)>0 or fad_register_id is not null,'Y','N')) as fad_fishing,
				newid() as art_effort_id,
				getdate() as entered_date, 'BASEPROD' as Entered_by
				into _EFFORT_TO_ADD
FROM [dbo].[PF_Artisanal_BASEPROD] BP
	Inner join dbo._TRIPS_TO_ADD T on T.py=BP.py and T.jdep=BP.jdep and T.jret=BP.jret and T.hdep = BP.hdep and BP.Hret = T.Hret and T.non_fishing_trip_reason_id is null
group by t.art_trip_id, BP.py, BP.base, BP.jdep, BP.jret, BP.hdep, BP.Hret, art_area_id, fish_method_id

-- select * from dbo._EFFORT_TO_ADD order by fad_register_id desc
-- select * from dbo._TRIPS_TO_ADD T --where T.non_fishing_trip_reason_id is null

BEGIN TRANSACTION
INSERT INTO Tufman2.art2.effort (art_trip_id, art_effort_id, entered_date, entered_by, art_area_id, fish_method_id, fad_register_id, fad_fishing)
select art_trip_id, art_effort_id, entered_date, entered_by, art_area_id, fish_method_id, fad_register_id, fad_fishing
FROM dbo._EFFORT_TO_ADD

-- COMMIT
-- ROLLBACK

/*

SELECT * FROM [dbo].[_EFFORT_TO_ADD] where position is not null
SELECT count(*) FROM [dbo].[_EFFORT_TO_ADD] where position is null

--- SELECT count(*) FROM [dbo].[_EFFORT_TO_ADD]
-- SELECT nbheure, count(*) FROM [dbo].PF_Artisanal_BASEPROD group by nbheure

Select count(*) from PF_Artisanal_BASEPROD_Origin where position is not null
Select count(*) from PF_Artisanal_BASEPROD where art_area_id is not null

BEGIN TRANSACTION
INSERT INTO Tufman2.art2.effort (art_trip_id, art_effort_id, hours_fished_n, entered_date, entered_by, art_area_id, fish_method_id, fad_fishing)
select art_trip_id, art_effort_id, hours_fished_n, entered_date, entered_by, art_area_id, fish_method_id, fad_fishing
FROM dbo._EFFORT_TO_ADD


SELECT
	E.fad_fishing, 
	E.fish_method_id, 
	E.hours_fished_n, 
	E.lines_n, 
	E.fuel_used_n, 
	E.fuel_type_id, 
	E.hooks_per_line_n, 
	E.live_bait_used, 
	E.hooks_n, 
	E.entered_date, 
	E.entered_by, 
	E.art_effort_id, 
	E.art_trip_id, 
	E.art_area_id, 
	E.fad_register_id
FROM
	tufman2.art2.effort AS E
	
	SELECT
	BP.PY, 
	BP.BASE, 
	BP.JDEP, 
	BP.JRET, 
	BP.HDEP, 
	BP.HRET, 
	BP.SORTIE, 
	BP.ESPECE, 
	BP.TAILLE, 
	BP.PDSA, 
	BP.NBRE, 
	BP.TYP, 
	BP.MER, 
	BP.VENT, 
	BP.PLUIE, 
	BP.REM, 
	BP.DETAIL, 
	BP.[POSITION], 
	BP.PU, 
	BP.PTOTAL, 
	BP.CIRCONS, 
	BP.ANNEE, 
	BP.CATEGORI, 
	BP.LICENCE_VA, 
	BP.ID, 
	BP.NBHEURE, 
	BP.NBMIN
FROM
	dbo.PF_Artisanal_BASEPROD AS BP

*/