IF OBJECT_ID('dbo._CATCH_TO_ADD', 'U') IS NOT NULL DROP TABLE dbo._CATCH_TO_ADD

-- generate the catch for each trip

SELECT  E.art_effort_id, BP.py, BP.base, BP.jdep, BP.jret, BP.hdep, BP.Hret, BP.art_area_id, BP.fish_method_id, nbre, PTOTAL,
				newid() as art_catch_id,
				BP.sp_id,
				convert(decimal(6,2),PTOTAL) as sp_kg,
				convert(int,Convert(decimal(6,2),NBRE)) as sp_n,
				getdate() as entered_date,
				'BASEPROD' as entered_by
				INTO dbo._CATCH_TO_ADD
FROM [dbo].[PF_Artisanal_BASEPROD] BP
		INNER JOIN dbo._Effort_TO_ADD E on E.py=BP.py and E.jdep=BP.jdep and E.jret=BP.jret 
				and E.jret = BP.jret and E.hdep = BP.hdep and BP.art_area_id = E.art_area_id and BP.fish_method_id = E.fish_method_id
WHERE BP.sp_id is not null

--select * from dbo._CATCH_TO_ADD
--select distinct ptotal FROM [dbo].[PF_Artisanal_BASEPROD_origin] BP order by 1

BEGIN TRANSACTION

insert into tufman2.art2.catch (art_effort_id, art_catch_id, sp_code, sp_kg, sp_n, entered_date, entered_by)
select art_effort_id, art_catch_id, sp_id, sp_kg, sp_n, entered_date, entered_by
FROM dbo._Catch_TO_ADD

-- COMMIT
-- ROLLBACK

