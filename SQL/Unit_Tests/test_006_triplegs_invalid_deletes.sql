select * from plan(1);

	-- 1. cannot delete the only tripleg of a trip 
		SELECT throws_ok(
		'SELECT * FROM apiv2.delete_tripleg(-16)',
		null,
		null,
		'should alert that it is not possible to delete the only tripleg of the trip'
		); 		

SELECT * FROM FINISH();
