DO $$
DECLARE
    user_id_to_check UUID := 'd069489e-31ee-446b-b2f3-9af8b2672b5a';
    user_email TEXT;
BEGIN
    -- This query runs with the permissions of the 'postgres' user, bypassing RLS
    SELECT email INTO user_email FROM auth.users WHERE id = user_id_to_check;
    
    IF user_email IS NOT NULL THEN
        -- This message will be printed to the terminal output by the Python script
        RAISE NOTICE 'Admin user email: %', user_email;
    ELSE
        RAISE NOTICE 'Admin user with ID % not found in auth.users.', user_id_to_check;
    END IF;
END $$;
