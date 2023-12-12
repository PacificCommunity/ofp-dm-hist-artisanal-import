-- insert PY_TO_ADD_T2_FORMATTED vessels to PF_Artisanal_2013_2016


BEGIN TRANSACTION

INSERT INTO tufman2.art2.vessels (vessel_name, vessel_date, mooring, ves_unique_id, vessel_id, visibility, date_completed,form_filled_by, vessel_length, fuel_type_id, motor_location, engine_power, vessel_hull_type, comments,is_active)
SELECT vessel_name, vessel_date, mooring, ves_unique_id, vessel_id, visibility, date_completed,form_filled_by, vessel_length, fuel_type_id, motor_location, engine_power, vessel_hull_type, comments, 1 
FROM dbo._VESSELS_TO_ADD

-- commit
-- ROLLBACK

/*
-- testing dups
select T2V.*
FROM TUFMAN2.art2.vessels T2V	
	inner join dbo.PY_TO_ADD_T2_FORMATTED V on v.ves_unique_id = T2V.ves_unique_id
	
	Select distinct vess_unique_id from dbo.PY_TO_ADD_T2_FORMATTED
	Select distinct ves_unique_id from tufman2.art2.vessels
*/