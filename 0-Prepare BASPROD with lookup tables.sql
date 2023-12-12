
IF OBJECT_ID('tempdb..#BaseProd1') IS NOT NULL DROP TABLE #BaseProd1
IF OBJECT_ID('tempdb..#BaseProd2') IS NOT NULL DROP TABLE #BaseProd2
IF OBJECT_ID('tempdb..#BaseProd3') IS NOT NULL DROP TABLE #BaseProd3
IF OBJECT_ID('tempdb..#BaseProd4') IS NOT NULL DROP TABLE #BaseProd4
IF OBJECT_ID('tempdb..#BaseProd5') IS NOT NULL DROP TABLE #BaseProd5


-- reformating positionconv to have unique records
IF OBJECT_ID('dbo.PF_Artisanal_PositionConv', 'U') IS NOT NULL DROP TABLE dbo.PF_Artisanal_PositionConv
SELECT
	PC.PY, 
	PC.base, 
	PC.positions_BASEPROD,
	min(positions_GRILLE_A_REMPLIR) as positions_GRILLE_A_REMPLIR,
	min(fad_name) as fad_name
	into dbo.PF_Artisanal_PositionConv
FROM
	dbo.PF_Artisanal_PositionConv_ORIGIN AS PC
GROUP BY
	PC.PY, 
	PC.base, 
	PC.positions_BASEPROD

-- reformating FishingMethod to have unique records
IF OBJECT_ID('dbo.TypeFishMethConv', 'U') IS NOT NULL DROP TABLE dbo.TypeFishMethConv

Select type_BASEPROD, min(FISHMETHOD_T2) as FISHMETHOD_T2, min(EXTRA_KEY) as extra_Key
	INTO dbo.TypeFishMethConv
From dbo.TypeFishMethConv_origin
GROUP BY type_BASEPROD

-- reformating SpeciesConv to have unique records
IF OBJECT_ID('dbo.PF_Artisanal_SpeciesConv', 'U') IS NOT NULL DROP TABLE dbo.PF_Artisanal_SpeciesConv

Select espece, min(trim(SC.sp_id)) as sp_id, max(raison) as raison
	INTO dbo.PF_Artisanal_SpeciesConv
From dbo.PF_Artisanal_SpeciesConv_ORIGIN SC
	inner join tufman2.ref.species T2S on T2s.sp_code = SC.sp_id
GROUP BY espece

-- select distinct sp_id from dbo.PF_Artisanal_SpeciesConv
--=====================================================================================================


-- applying 1st position conversion lookup to baseprod
SELECT IIF(PC.positions_GRILLE_A_REMPLIR is null, position, PC.positions_GRILLE_A_REMPLIR) as new_pos, fad_name,
	BP.*
	INTO #BaseProd1
FROM dbo.PF_Artisanal_BASEPROD_ORIGIN AS BP
	LEFT JOIN dbo.PF_Artisanal_PositionConv AS PC ON 
		BP.PY = PC.PY AND
		BP.BASE = PC.base AND
		BP.[POSITION] = PC.positions_BASEPROD

Select count(*) from #baseProd1

----------------------------------------------------------------
-- getting the area ID from the NEW_POS
SElect A.art_area_id, BP.*
	INTO #BaseProd2
FROM #BaseProd1 AS BP
	left join tufman2.art2.areas A on BP.new_pos = A.Art_area_name and A.visibility = 1024

/*
-- check that there are not several T2 areas that match the position
select BP.new_pos, count(*),min(A.Art_area_name) as min_area, max(A.Art_area_name) as max_area
FROM #BaseProd1 AS BP
	left join tufman2.art2.areas A on BP.new_pos = A.Art_area_name and A.visibility = 1024
GROUP BY BP.new_pos
HAVING count(*)>1 and min(A.Art_area_name) <> max(A.Art_area_name)
*/

-- Select count(*) from #baseProd2
----------------------------------------------------------------

-- getting the fishing technique from lookups
SElect FTC.FISHMETHOD_T2 as fish_method_id, BP.*
	INTO #BaseProd3
FROM #BaseProd2 AS BP
	Left join dbo.TypeFishMethConv FTC on BP.typ = FTC.type_BASEPROD 

-- Select count(*) from #baseProd3 where typ is not null
-- Select count(*) from dbo.PF_Artisanal_BASEPROD_Origin where typ is not null

-- getting the FAD_REGISTER from T2 lookup table
SElect 	FR.fad_register_id, BP.*
	INTO #BaseProd4
FROM #BaseProd3 AS BP
	left join tufman2.art2.FAD_REGISTER FR on BP.fad_name = FR.fad_name and FR.visibility = 1024

-- Select count(*) from #baseProd4

-- getting the species code
SElect 	SC.sp_id, SC.raison, BP.*
	INTO #BaseProd5
FROM #BaseProd4 AS BP
	left join dbo.PF_Artisanal_SpeciesConv SC on BP.ESPECE = SC.ESPECE

-- Select count(*) from #baseProd5

-- recreating BASEPROD with all proper T2 ids

IF OBJECT_ID('dbo.PF_Artisanal_BASEPROD', 'U') IS NOT NULL DROP TABLE dbo.PF_Artisanal_BASEPROD

Select * into PF_Artisanal_BASEPROD 
from #BaseProd5

-- Select count(*) from dbo.PF_Artisanal_BASEPROD
select distinct sp_id from dbo.PF_Artisanal_BASEPROD
		
/*

SELECT
	BP.PY, 
	BP.BASE, 
	BP.POSITION as Position_old,
	PC.positions_GRILLE_A_REMPLIR as POSITION, 
	BP.JDEP, 
	BP.JRET, 
	BP.ESPECE, 
	BP.HDEP, 
	BP.HRET, 
	BP.SORTIE, 
	BP.TAILLE, 
	BP.PDSA, 
	BP.NBRE, 
	BP.TYP, 
	BP.MER, 
	BP.VENT, 
	BP.PLUIE, 
	BP.REM, 
	BP.PU, 
	BP.PTOTAL, 
	BP.CIRCONS, 
	BP.ANNEE, 
	BP.CATEGORI, 
	BP.LICENCE_VA, 
	BP.ID, 
	BP.NBHEURE, 
	BP.NBMIN, 
	BP.DETAIL
FROM
	dbo.PF_Artisanal_BASEPROD AS BP
	LEFT JOIN
	dbo.PF_Artisanal_PositionConv AS PC
	ON 
		BP.PY = PC.PY AND
		BP.BASE = PC.base AND
		BP.[POSITION] = PC.positions_BASEPROD
		
	*/