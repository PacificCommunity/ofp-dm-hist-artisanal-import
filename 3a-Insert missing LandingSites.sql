IF OBJECT_ID('tempdb..#Landing1') IS NOT NULL DROP TABLE #Landing1
IF OBJECT_ID('tempdb..#Landing2') IS NOT NULL DROP TABLE #Landing2

-- listing all landing sites which are already in T2
SELECT distinct trim(BP.base) as base
	INTO #Landing1
FROM dbo.PF_Artisanal_BASEPROD BP
		LEFT JOIN dbo.station S on s.BASE = BP.base
		INNER JOIN TUFMAN2.art2.landing_sites LS on charindex(BP.BASE,LS.landing_site_name)>0 and LS.visibility = 1024
		inner JOIN TUFMAN2.art2.regions R on R.region_id = LS.region_id

-- all distinct landing sites which are not in T2 yet, to be added
Select distinct BP.base
	into #Landing2
FROM dbo.PF_Artisanal_BASEPROD BP
WHERE Trim(BP.BASE) not in (select base from #landing1)


BEGIN TRANSACTION

INSERT INTO tufman2.art2.landing_sites (landing_site_name, region_id, landing_site_id, visibility, entered_date, entered_by)
select distinct TRIM(BP.BASE) as landing_site_name, R.region_id, newid() as landing_site_id, 1024 as visibility, getdate() as entered_date, 'BASEPROD' as entered_by
FROM #Landing2 BP
		inner JOIN dbo.station S on s.BASE = BP.base
		left JOIN TUFMAN2.art2.regions R on R.region_name = S.CIRCONS
		
		
	-- COMMIT
	-- ROLLBACK	