IF OBJECT_ID('dbo._SIZE_TO_ADD', 'U') IS NOT NULL DROP TABLE dbo._SIZE_TO_ADD

-- generate the SIZE data for each catch (when size exist)

SELECT  C.art_catch_id,
				newid() as size_data_id,
				convert(int,convert(decimal(6,2),BP.taille)) as sp_len,
				getdate() as entered_date,
				'BASEPROD' as entered_by
				INTO dbo._SIZE_TO_ADD
FROM [dbo].[PF_Artisanal_BASEPROD] BP
		INNER JOIN dbo._CATCH_TO_ADD C on C.py = BP.py and C.jdep = BP.jdep and C.jret = BP.jret 
				and C.jret = BP.jret and C.hdep = BP.hdep and BP.art_area_id = C.art_area_id and BP.fish_method_id = C.fish_method_id
				and C.sp_id = BP.sp_id and C.nbre = BP.nbre and C.sp_kg = BP.PTOTAL
WHERE BP.sp_id is not null and bp.taille is not null and convert(decimal(6,2),BP.taille)<>0

-- select * from dbo._SIZE_TO_ADD order by sp_len desc
-- select * from dbo.PF_Artisanal_BASEPROD where taille is not null

BEGIN TRANSACTION

insert into tufman2.art2.size_data (size_data_id, art_catch_id, sp_len, entered_date, entered_by)
select size_data_id, art_catch_id, sp_len, entered_date, entered_by
FROM dbo._SIZE_TO_ADD

-- COMMIT
-- ROLLBACK
