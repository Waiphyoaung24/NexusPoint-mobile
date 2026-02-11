# Organization Setup Guide

## Problem: 404 Error & Empty Organizations

If you're seeing these errors:
```
DioError Status: 404 Not Found
https://420man.store/api/organization/list

🏢 Found 0 organizations
❌ User has no organizations
```

## Root Cause

1. **404 Error (Fixed)**: The Flutter app was trying wrong endpoints. Now it correctly tries:
   - `organization/list` (singular) ✅
   - Multiple fallback endpoints

2. **0 Organizations**: The user account exists but is not assigned to any organization in the database.

## Solution: Create & Assign Organization

### Quick Fix (Recommended)

Use the provided script:

```bash
cd scripts
chmod +x create_test_organization.sh
./create_test_organization.sh
```

**Note**: Update `YOUR_OTP_HERE` in the script with your actual OTP.

### Manual Fix (Database)

If you have direct database access:

```sql
-- 1. Create Organization
INSERT INTO organization (id, name, slug, created_at, updated_at)
VALUES (
  '123e4567-e89b-12d3-a456-426614174000', -- Use your own UUID
  'Test Restaurant',
  'test-restaurant',
  NOW(),
  NOW()
);

-- 2. Assign User to Organization
INSERT INTO member (id, organization_id, user_id, role, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  '123e4567-e89b-12d3-a456-426614174000', -- Organization ID from step 1
  '8281eba5-09bb-4315-84be-2dfb78a0e51b', -- Your user ID
  'owner',
  NOW(),
  NOW()
);

-- 3. Set as Active Organization
UPDATE session
SET active_organization_id = '123e4567-e89b-12d3-a456-426614174000'
WHERE user_id = '8281eba5-09bb-4315-84be-2dfb78a0e51b';
```

### Manual Fix (API)

Use curl or Postman:

#### 1. Login
```bash
curl -X POST https://420man.store/api/auth/sign-in/email-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "entertainmentkwg@gmail.com",
    "otp": "YOUR_OTP"
  }'
```

Save the token from the response.

#### 2. Create Organization
```bash
curl -X POST https://420man.store/api/organization/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "Test Restaurant",
    "slug": "test-restaurant"
  }'
```

Save the organization ID from the response.

#### 3. Set Active Organization
```bash
curl -X POST https://420man.store/api/organization/setActive \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "organizationId": "YOUR_ORG_ID"
  }'
```

#### 4. Verify
```bash
curl -X GET https://420man.store/api/organization/list \
  -H "Authorization: Bearer YOUR_TOKEN"
```

You should see your organization in the response.

## Verify Setup

After creating the organization:

1. **Run the Flutter app**:
   ```bash
   flutter run --flavor prod
   ```

2. **Check console output**:
   ```
   ✅ Active Organization ID: 123e4567-e89b-12d3-a456-426614174000
   ```

3. **Menu should load successfully**:
   ```
   Fetching menu items for organization: 123e4567-e89b-12d3-a456-426614174000
   ```

## Correct Endpoints Reference

The Flutter app now correctly uses:

### Authentication
- `POST /api/auth/sign-in/email-otp` - Login with OTP
- `GET /api/auth/get-session` - Get current session

### Organizations
- `GET /api/organization/list` - List user's organizations (⚠️ Singular "organization")
- `POST /api/organization/setActive` - Set active organization
- `POST /api/organization/create` - Create new organization (if available)

### Menu Items
- `GET /api/v1/menu-items?tenant_id={organizationId}` - Get menu items

## Troubleshooting

### Still getting 404?

Check your backend logs to see what endpoints are actually available:
- The endpoint might be tRPC-based
- The path might be different
- Authentication might be required

### Still getting 0 organizations?

1. Check if user exists in database:
   ```sql
   SELECT * FROM user WHERE email = 'entertainmentkwg@gmail.com';
   ```

2. Check if organization exists:
   ```sql
   SELECT * FROM organization;
   ```

3. Check if membership exists:
   ```sql
   SELECT * FROM member WHERE user_id = '8281eba5-09bb-4315-84be-2dfb78a0e51b';
   ```

4. Check session active organization:
   ```sql
   SELECT * FROM session WHERE user_id = '8281eba5-09bb-4315-84be-2dfb78a0e51b';
   ```

## Next Steps

After fixing the organization setup:

1. ✅ User can login successfully
2. ✅ Organization is automatically selected
3. ✅ Menu items load with correct `tenant_id`
4. ✅ Orders can be created with correct `tenantId` and `branchId`

## Need Help?

If you're still having issues:

1. **Check the console logs** - The Flutter app now provides detailed debugging output
2. **Check backend logs** - See what requests are hitting the server
3. **Verify database schema** - Ensure tables exist and have correct structure
4. **Check Better Auth setup** - Ensure authentication is working correctly
