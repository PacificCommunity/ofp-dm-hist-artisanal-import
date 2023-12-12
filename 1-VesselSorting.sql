IF OBJECT_ID('tempdb..#PY_TO_ADD') IS NOT NULL DROP TABLE #PY_TO_ADD

-- selecting all the vessels that are not yet defined in T2 and which PY matches the definition in the PY_UNIQUE ref table.
-- These vessel definitions should all be added to ART2.Vessels
Select distinct pu.* into #PY_TO_ADD
from [dbo].[PF_Artisanal_BASEPROD] BP
	inner join dbo.PY_UNIQUE PU on pu.py = bp.py
Where bp.py not IN
		(
		-- listing all vessels that are already in TUFMAN2
		SELECT distinct BP.PY 
		FROM [dbo].[PF_Artisanal_BASEPROD] BP
				inner join Tufman2.[art2].[vessels] V ON [ves_unique_id] IS NOT NULL 
						 and trim(BP.PY) = trim(V.ves_unique_id)
		)
-- [ves_unique_id] IS NOT NULL AND [owner_island] LIKE N'%TAHITI%' and (charindex(BP.PY,V.vesselname)>0 or charindex(BP.PY,V.ves_unique_id)>0) 

/*
--Listing all vessels that won't be imported because we don't have a correspondance PY reference anywhere
Select distinct convert(int,BP.PY)
from [dbo].[PF_Artisanal_BASEPROD] BP
WHERE PY not in (select PY from dbo.py_to_add_to_T2)
	and py not in (SELECT BP.PY 
		FROM [dbo].[PF_Artisanal_BASEPROD] BP
				inner join Tufman2.[art2].[vessels] V ON [ves_unique_id] IS NOT NULL AND [owner_island] LIKE N'%TAHITI%' and trim(BP.PY) = trim(V.ves_unique_id)
				)
order by 1
*/

IF OBJECT_ID('dbo._VESSELS_TO_ADD', 'U') IS NOT NULL DROP TABLE dbo._VESSELS_TO_ADD

-- Listing all vessels details for boats to add, for T2
Select null as counter, CONCAT(PY,' - ',BATEAU) as vessel_name, IIF(DATECREAT is null,getdate(),DATECREAT ) as vessel_date, 
			ATTACHE as mooring,
			Convert(nvarchar(4),PY) as ves_unique_id, newid() as vessel_id, 1024 as visibility, getdate() as date_completed,
			'BASEPROD' as form_filled_by, LONGUEUR as vessel_length,
			IIF(charindex('ESSENCE',CARBURANT)>0,2,IIF(charindex('DIESEL',CARBURANT)>0,1,null)) as fuel_type_id,
			IIF(charindex('IN',MOTEUR_TYPE)>0,'I',IIF(charindex('HO',MOTEUR_TYPE)>0,'O',null)) as motor_location,
			PUISSANCE as engine_power,
			CASE 
				WHEN type='BON' then 'PL'
				WHEN type='PMI' then 'PO'
				WHEN type='PMDH' then 'PO'
				WHEN type='SBON' then 'PL'
				WHEN type='TH' then 'LL'
				WHEN type='PMH' then 'PO'
				WHEN type='PMDI' then 'PO'
				ELSE null
			END
			as vessel_hull_type,
			--IIF(charindex('BON',type)>0,'BO',IIF(charindex('PO',TYPE)>0,'PO',null)) as vessel_hull_type,
			OBSERVATIO as comments
			into dbo._VESSELS_TO_ADD
FROM #PY_TO_ADD

--select distinct type from [dbo].py_unique
