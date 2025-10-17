# Grafana ECS Deployment with CDK

This CDK app deploys Grafana with the Aliyun Log Service plugin to AWS ECS using Fargate.

## Prerequisites

- AWS CLI configured with `spl` profile
- Node.js and npm installed
- Docker installed (for building the container image)

## Quick Deploy

```bash
# Make script executable and deploy
chmod +x deploy.sh
./deploy.sh
```

## Manual Deployment

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Bootstrap CDK (first time only)
AWS_PROFILE=spl cdk bootstrap

# Deploy
AWS_PROFILE=spl cdk deploy
```

## Architecture

The CDK stack creates:

- **VPC**: New VPC with public/private subnets across 2 AZs
- **ECS Cluster**: Fargate cluster with container insights enabled
- **Application Load Balancer**: Public ALB for accessing Grafana
- **ECS Service**: Fargate service running the Grafana container
- **CloudWatch Logs**: Log group for container logs
- **Security Groups**: Proper security group configuration

## Configuration

The Grafana container is configured with:
- Aliyun Log Service plugin pre-installed
- Default admin credentials: `admin/admin`
- Port 3000 exposed via ALB on port 80
- Environment variables for plugin loading

## Access

After deployment:
1. Get the ALB URL from CDK output
2. Access Grafana at `http://<alb-url>`
3. Login with `admin/admin`
4. Configure Aliyun Log Service data source

## Monitoring

Check deployment status:
```bash
aws ecs describe-services --profile spl \
  --cluster GrafanaEcsStack-GrafanaCluster* \
  --services GrafanaEcsStack-GrafanaService*
```

View logs:
```bash
aws logs tail /ecs/grafana-aliyun --profile spl --follow
```

## Cleanup

```bash
AWS_PROFILE=spl cdk destroy
```

## Customization

Edit `lib/grafana-ecs-stack.ts` to:
- Change instance size (CPU/memory)
- Add custom environment variables
- Configure SSL/TLS
- Add custom domain
- Modify security groups