import * as cdk from 'aws-cdk-lib';
import * as acm from 'aws-cdk-lib/aws-certificatemanager';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as ecsPatterns from 'aws-cdk-lib/aws-ecs-patterns';
import * as elbv2 from 'aws-cdk-lib/aws-elasticloadbalancingv2';
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

    // Add container to task definition
    const container = taskDefinition.addContainer('grafana', {
      image: ecs.ContainerImage.fromRegistry('grafana/grafana:latest'),
      environment: {
        GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS: 'aliyun-log-service-datasource',
        GF_SECURITY_ADMIN_USER: 'admin',
        GF_SECURITY_ADMIN_PASSWORD: 'admin',
        GF_INSTALL_PLUGINS: 'https://github.com/aliyun/aliyun-log-grafana-datasource-plugin/archive/refs/heads/master.zip;aliyun-log-datasource',
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

    // Create ACM Certificate for HTTPS
    const certificate = new acm.Certificate(this, 'GrafanaCertificate', {
      domainName: 'logs.servers8.com',
      validation: acm.CertificateValidation.fromDns(), // DNS validation
    });

    // Create Fargate Service with Application Load Balancer
    const fargateService = new ecsPatterns.ApplicationLoadBalancedFargateService(this, 'GrafanaService', {
      cluster,
      taskDefinition,
      desiredCount: 1,
      publicLoadBalancer: true,
      listenerPort: 80,
    });

    // Add HTTPS listener with certificate
    fargateService.loadBalancer.addListener('HTTPSListener', {
      port: 443,
      certificates: [certificate],
      defaultAction: elbv2.ListenerAction.forward([fargateService.targetGroup]),
    });

    // Configure health check
    fargateService.targetGroup.configureHealthCheck({
      path: '/login',
      healthyHttpCodes: '200',
    });

    // Output the Load Balancer URL
    new cdk.CfnOutput(this, 'GrafanaUrl', {
      value: `https://${fargateService.loadBalancer.loadBalancerDnsName}`,
      description: 'Grafana URL',
    });

    // Output default credentials
    new cdk.CfnOutput(this, 'DefaultCredentials', {
      value: 'Username: admin, Password: admin',
      description: 'Default Grafana credentials',
    });
  }
}