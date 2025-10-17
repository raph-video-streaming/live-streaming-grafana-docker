#!/bin/bash

# Grafana ECS Deployment Script with SPL Profile

set -e

AWS_PROFILE="spl"

echo "🚀 Deploying Grafana with Aliyun Plugin to ECS using profile: $AWS_PROFILE"

# Check if AWS CLI is configured with spl profile
if ! aws sts get-caller-identity --profile $AWS_PROFILE > /dev/null 2>&1; then
    echo "❌ AWS CLI profile '$AWS_PROFILE' is not configured or invalid."
    echo "Please run 'aws configure --profile $AWS_PROFILE' first."
    exit 1
fi

# Check if CDK is installed
if ! command -v cdk &> /dev/null; then
    echo "❌ AWS CDK is not installed. Installing..."
    npm install -g aws-cdk
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build the project
echo "🔨 Building TypeScript..."
npm run build

# Bootstrap CDK (if needed)
echo "🏗️ Bootstrapping CDK..."
AWS_PROFILE=$AWS_PROFILE cdk bootstrap

# Deploy the stack
echo "🚀 Deploying to AWS..."
AWS_PROFILE=$AWS_PROFILE cdk deploy --require-approval never

echo "✅ Deployment completed!"
echo ""
echo "📋 Next steps:"
echo "1. Wait for the ECS service to be healthy (2-3 minutes)"
echo "2. Access Grafana using the URL from the output"
echo "3. Login with admin/admin credentials"
echo "4. Configure Aliyun Log Service data source"
echo ""
echo "🔍 To check deployment status:"
echo "   aws ecs describe-services --profile $AWS_PROFILE --cluster GrafanaEcsStack-GrafanaCluster* --services GrafanaEcsStack-GrafanaService*"