import * as cdk from 'aws-cdk-lib';
import * as acm from 'aws-cdk-lib/aws-certificatemanager';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as efs from 'aws-cdk-lib/aws-efs';
import * as elbv2 from 'aws-cdk-lib/aws-elasticloadbalancingv2';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as logs from 'aws-cdk-lib/aws-logs';
import { Construct } from 'constructs';

export class GrafanaEcsStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create VPC
    const vpc = new ec2.Vpc(this, 'GrafanaVpc', {
      maxAzs: 2,
      natGateways: 1,
    });

    // Create ECS Cluster
    const cluster = new ecs.Cluster(this, 'GrafanaCluster', {
      vpc,
      containerInsights: true,
    });

    // Create CloudWatch Log Group
    const logGroup = new logs.LogGroup(this, 'GrafanaLogGroup', {
      logGroupName: '/ecs/grafana-aliyun',
      retention: logs.RetentionDays.ONE_WEEK,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    // Create task definition
    const taskDefinition = new ecs.FargateTaskDefinition(this, 'GrafanaTaskDef', {
      memoryLimitMiB: 1024,
      cpu: 512,
    });

    // Add EFS volume configuration - using existing EFS without access point
    taskDefinition.addVolume({
      name: 'grafana-storage',
      efsVolumeConfiguration: {
        fileSystemId: 'fs-04936b2a1f6295763',
        rootDirectory: '/',
        transitEncryption: 'DISABLED'  // Disable encryption for simplicity
      },
    });

    // Add container to task definition
    const container = taskDefinition.addContainer('grafana', {
      image: ecs.ContainerImage.fromRegistry('grafana/grafana:latest'),
      environment: {
        GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS: 'aliyun-log-service-datasource',
        GF_INSTALL_PLUGINS: 'https://github.com/aliyun/aliyun-log-grafana-datasource-plugin/archive/refs/heads/master.zip;aliyun-log-service-datasource',
        GF_SECURITY_ADMIN_USER: 'admin',
        GF_SECURITY_ADMIN_PASSWORD: 'admin',
        GF_PATHS_PLUGINS: '/var/lib/grafana/plugins',
      },
      logging: ecs.LogDrivers.awsLogs({
        streamPrefix: 'grafana',
        logGroup,
      }),
    });

    container.addPortMappings({
      containerPort: 3000,
      protocol: ecs.Protocol.TCP,
    });

    // Mount EFS volume to /var/lib/grafana
    container.addMountPoints({
      sourceVolume: 'grafana-storage',
      containerPath: '/var/lib/grafana',
      readOnly: false,
    });

    // Create ECS Fargate Service
    const fargateService = new ecs.FargateService(this, 'GrafanaService', {
      cluster,
      taskDefinition,
      desiredCount: 1,
      assignPublicIp: true,
    });

    // Create Application Load Balancer (HTTP only for now)
    const alb = new elbv2.ApplicationLoadBalancer(this, 'GrafanaALB', {
      vpc,
      internetFacing: true,
    });

    const httpListener = alb.addListener('HttpListener', {
      port: 80,
      protocol: elbv2.ApplicationProtocol.HTTP,
      open: true,
    });

    // Forward to ECS service on container port 3000 with health check
    httpListener.addTargets('GrafanaTargets', {
      port: 3000,
      protocol: elbv2.ApplicationProtocol.HTTP,
      targets: [fargateService.loadBalancerTarget({
        containerName: 'grafana',
        containerPort: 3000,
      })],
      healthCheck: {
        path: '/login',
        healthyHttpCodes: '200',
      },
    });

    // Output the Load Balancer URL
    new cdk.CfnOutput(this, 'GrafanaUrl', {
      value: `http://${alb.loadBalancerDnsName}`,
      description: 'Grafana URL',
    });

    // Output default credentials
    new cdk.CfnOutput(this, 'DefaultCredentials', {
      value: 'Username: admin, Password: admin',
      description: 'Default Grafana credentials',
    });
  }
}