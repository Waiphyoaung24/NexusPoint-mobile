#!/bin/bash

# Script to create a test organization for the user
# Usage: ./create_test_organization.sh

API_URL="https://nexuslab.asia"
USER_EMAIL="entertainmentkwg@gmail.com"

echo "🚀 Creating test organization for user: $USER_EMAIL"
echo "📍 API URL: $API_URL"
echo ""

# Step 1: Login to get auth token
echo "1️⃣  Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/api/auth/sign-in/email-otp" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "'$USER_EMAIL'",
    "otp": "YOUR_OTP_HERE"
  }')

echo "Login Response: $LOGIN_RESPONSE"
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.session.token // .token')

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo "❌ Failed to get auth token"
  exit 1
fi

echo "✅ Auth token obtained"
echo ""

# Step 2: Create Organization
echo "2️⃣  Creating test organization..."
CREATE_ORG_RESPONSE=$(curl -s -X POST "$API_URL/api/organization/create" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Test Restaurant",
    "slug": "test-restaurant"
  }')

echo "Create Org Response: $CREATE_ORG_RESPONSE"
ORG_ID=$(echo $CREATE_ORG_RESPONSE | jq -r '.id // .organizationId')

if [ "$ORG_ID" == "null" ] || [ -z "$ORG_ID" ]; then
  echo "❌ Failed to create organization"
  echo "Response: $CREATE_ORG_RESPONSE"
  exit 1
fi

echo "✅ Organization created: $ORG_ID"
echo ""

# Step 3: Set as Active Organization
echo "3️⃣  Setting as active organization..."
SET_ACTIVE_RESPONSE=$(curl -s -X POST "$API_URL/api/organization/setActive" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "organizationId": "'$ORG_ID'"
  }')

echo "Set Active Response: $SET_ACTIVE_RESPONSE"
echo "✅ Active organization set"
echo ""

# Step 4: Verify
echo "4️⃣  Verifying setup..."
ORG_LIST=$(curl -s -X GET "$API_URL/api/organization/list" \
  -H "Authorization: Bearer $TOKEN")

echo "Organization List: $ORG_LIST"
echo ""
echo "✅ Setup complete!"
echo "🏢 Your organization ID: $ORG_ID"
echo "📱 You can now login to the Flutter app"
