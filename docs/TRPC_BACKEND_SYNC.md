# Flutter ↔️ tRPC Backend Integration

## ✅ Fixed: Code Now Matches Backend Implementation

### Backend tRPC Procedures (from `organizationRouter`):

```typescript
export const organizationRouter = router({
  list: protectedProcedure.query(...)           // Get user's organizations
  setActive: protectedProcedure.mutation(...)   // Set active organization
  create: protectedProcedure.mutation(...)      // Create new organization
  members: protectedProcedure.query(...)        // Get organization members
  invite: protectedProcedure.mutation(...)      // Invite member
  acceptInvite: protectedProcedure.mutation(...) // Accept invitation
});
```

### Flutter Implementation (Updated):

```dart
// ✅ organization.list - tRPC Query
Future<List<Organization>> getUserOrganizations()
  → Calls: trpc/organization.list (GET)
  → Returns: Array of { id, name, slug, logo, role }

// ✅ organization.setActive - tRPC Mutation
Future<void> setActiveOrganization(String organizationId)
  → Calls: trpc/organization.setActive (POST)
  → Input: { organizationId }

// ✅ organization.create - tRPC Mutation
Future<Organization> createOrganization(...)
  → Calls: trpc/organization.create (POST)
  → Input: { name, slug, description? }
```

## 🔍 Why User Has 0 Organizations

The backend query performs an **INNER JOIN**:

```sql
SELECT organization.*, member.role
FROM organization
INNER JOIN member ON member.organizationId = organization.id
WHERE member.userId = :userId
```

**Result**: If there's no row in the `member` table for the user, the query returns an empty array.

### Current State:
- ✅ User exists in `user` table
- ❌ User has NO entries in `member` table
- ❌ Therefore, `organization.list` returns `[]`

## 🛠️ Solution: Add User to Organization

### Option 1: SQL (Recommended - Fast)

```bash
psql your_database < scripts/seed_organization.sql
```

This will:
1. Create "Test Restaurant" organization
2. Add user as "owner" in `member` table
3. Set as active organization in `session` table
4. Verify the setup

### Option 2: tRPC API (If you have admin access)

```typescript
// 1. Create organization (as any authenticated user)
const org = await trpc.organization.create.mutate({
  name: "Test Restaurant",
  slug: "test-restaurant",
  description: "Development test org"
});

// User is automatically added as owner

// 2. Set as active
await trpc.organization.setActive.mutate({
  organizationId: org.id
});
```

### Option 3: Direct Database Insert

```sql
-- Insert into member table
INSERT INTO member ("organizationId", "userId", role, "createdAt", "updatedAt")
VALUES (
  'existing-org-id-here',
  '8281eba5-09bb-4315-84be-2dfb78a0e51b',
  'owner',
  NOW(),
  NOW()
);

-- Update session
UPDATE session
SET "activeOrganizationId" = 'existing-org-id-here'
WHERE "userId" = '8281eba5-09bb-4315-84be-2dfb78a0e51b';
```

## 📝 Database Schema (from backend)

### Tables Involved:

```sql
-- organization
CREATE TABLE organization (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  logo TEXT,
  metadata TEXT,
  "createdAt" TIMESTAMP,
  "updatedAt" TIMESTAMP
);

-- member (junction table for users ↔️ organizations)
CREATE TABLE member (
  id TEXT PRIMARY KEY,
  "organizationId" TEXT REFERENCES organization(id),
  "userId" TEXT REFERENCES user(id),
  role TEXT, -- 'owner', 'admin', 'member'
  "createdAt" TIMESTAMP,
  "updatedAt" TIMESTAMP
);

-- session (Better Auth sessions)
CREATE TABLE session (
  id TEXT PRIMARY KEY,
  "userId" TEXT,
  token TEXT,
  "activeOrganizationId" TEXT REFERENCES organization(id),
  "createdAt" TIMESTAMP,
  "expiresAt" TIMESTAMP
);
```

## 🔄 Full Flow After Fix

### 1. User Logs In
```
POST /api/auth/sign-in/email-otp
Response: { session: { token, activeOrganizationId? }, user: {...} }
```

### 2. If activeOrganizationId is null → Fetch Organizations
```
GET /trpc/organization.list?batch=1&input={"0":{"json":null}}
Response: [{ id, name, slug, logo, role }]
```

### 3. If 1 Organization → Auto-Select
```
POST /trpc/organization.setActive
Body: {"0":{"json":{"organizationId":"..."}}}
Response: { success: true }
```

### 4. Refresh Session
```
GET /api/auth/get-session
Response: { session: { activeOrganizationId: "..." }, user: {...} }
```

### 5. Fetch Menu Items
```
GET /api/v1/menu-items?tenant_id={activeOrganizationId}
Response: [{ menu items... }]
```

## ✅ Verify Setup

After running the SQL:

1. **Check member table**:
   ```sql
   SELECT * FROM member WHERE "userId" = '8281eba5-09bb-4315-84be-2dfb78a0e51b';
   ```
   Should return at least 1 row.

2. **Check session**:
   ```sql
   SELECT "activeOrganizationId" FROM session
   WHERE "userId" = '8281eba5-09bb-4315-84be-2dfb78a0e51b';
   ```
   Should have an organization ID.

3. **Run Flutter app**:
   ```bash
   flutter run --flavor prod
   ```

4. **Expected console output**:
   ```
   📦 Raw Auth Response: {...}
   🏢 Active Organization ID: xxx-xxx-xxx
   ✅ Active Organization ID: xxx-xxx-xxx
   Fetching menu items for organization: xxx-xxx-xxx
   ```

## 🎯 Next Steps

1. **Run the SQL**: `psql your_db < scripts/seed_organization.sql`
2. **Test the app**: `flutter run --flavor prod`
3. **Verify menu loads**: Check console for successful API calls

## 📚 Backend Reference

The tRPC procedures are defined in:
- `apps/api/src/routers/organization.ts`

Key security notes from backend:
- All procedures except `getInvite` are **protected** (require authentication)
- `list` returns only organizations where user is a member
- `setActive` verifies user membership before updating session
- `create` automatically adds creator as "owner"
