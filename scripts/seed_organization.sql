-- Create a test organization and assign user to it
-- Using snake_case column names (matches actual database schema)

-- CHANGE THIS: Replace with your actual user ID
-- User ID from logs: 929afbf9-09e8-4d1e-ae29-19bb6f625994

-- Step 1: Create Organization
DO $$
DECLARE
  new_org_id TEXT;
  target_user_id TEXT := '929afbf9-09e8-4d1e-ae29-19bb6f625994'; -- ← CHANGE THIS
BEGIN
  -- Insert organization
  INSERT INTO organization (name, slug, metadata, logo, created_at, updated_at)
  VALUES (
    'Test Restaurant',
    'test-restaurant',
    'Development test organization',
    NULL,
    NOW(),
    NOW()
  )
  RETURNING id INTO new_org_id;

  RAISE NOTICE 'Created organization with ID: %', new_org_id;

  -- Step 2: Add user as owner (member)
  INSERT INTO member (organization_id, user_id, role, created_at, updated_at)
  VALUES (
    new_org_id,
    target_user_id,
    'owner',
    NOW(),
    NOW()
  );

  RAISE NOTICE 'Added user as owner';

  -- Step 3: Set as active organization in all user sessions
  UPDATE session
  SET active_organization_id = new_org_id
  WHERE user_id = target_user_id;

  RAISE NOTICE 'Updated session(s) with active organization';

  -- Step 4: Verify
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Setup Complete!';
  RAISE NOTICE 'Organization ID: %', new_org_id;
  RAISE NOTICE 'User ID: %', target_user_id;
  RAISE NOTICE '========================================';
END $$;

-- Verify the setup (using correct snake_case column names)
SELECT
    o.id AS org_id,
    o.name AS org_name,
    o.slug AS org_slug,
    m.user_id AS user_id,
    m.role AS user_role,
    s.active_organization_id AS active_in_session
FROM
    organization o
JOIN
    member m ON o.id = m.organization_id
LEFT JOIN
    session s ON s.user_id = m.user_id
    AND s.active_organization_id = o.id
WHERE
    m.user_id = '929afbf9-09e8-4d1e-ae29-19bb6f625994'; -- ← CHANGE THIS

-- Check if there are any sessions without active organization
SELECT
  id as session_id,
  user_id,
  active_organization_id,
  created_at
FROM session
WHERE user_id = '929afbf9-09e8-4d1e-ae29-19bb6f625994'; -- ← CHANGE THIS
