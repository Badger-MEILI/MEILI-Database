select * from plan(3); 

	-- 1. CHECK FOR CORRECT USER ID
	SELECT set_eq(
		'select * from raw_data.login_user($bd$foo@user.com$bd$, $bd$foopassword$bd$)',
		'select id from raw_data.user_table where username = $bd$foo@user.com$bd$',
		'checking if the correct user id is returned by the login function');
	-- 2. CHECK THAT THE WRONG PASSWORD RETURNS AN EMPTY RESULT
	SELECT bag_hasnt(
		'select * from raw_data.login_user($bd$foo@user.com$bd$, $bd$wrongfoopassword$bd$)', 
		'select id from raw_data.user_table where username = $bd$foo@user.com$bd$',
		'wrong password should return empty result');

	-- 3. CHECK THAT THE PRIMARY KEY ON USER TABLE IS RESPECTED
	SELECT throws_ok(
		'INSERT INTO raw_data.user_table VALUES (-1, $bd$secondfoo@user.com$bd$, crypt($bd$foopassword$bd$, gen_salt($bd$bf$bd$,8)), $bd$foo_phone$bd$, $bd$foo_os$bd$);',
		null,
		null,
		'should get unique violation of primary key constraint'
		);

SELECT * FROM FINISH();
