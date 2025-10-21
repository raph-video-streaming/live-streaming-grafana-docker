import * as cdk from 'aws-cdk-lib';
import * as acm from 'aws-cdk-lib/aws-certificatemanager';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecs from 'aws-cdk-lib/aws-ecs';
// import * as ecsPatterns from 'aws-cdk-lib/aws-ecs-patterns';
import * as efs from 'aws-cdk-lib/aws-efs';
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

    // Create EFS Security Group
    const efsSecurityGroup = new ec2.SecurityGroup(this, 'EfsSecurityGroup', {
      vpc,
      description: 'Security group for EFS',
      allowAllOutbound: false,
    });

    // Create EFS File System
    const fileSystem = new efs.FileSystem(this, 'GrafanaEfs', {
      vpc,
      securityGroup: efsSecurityGroup,
      performanceMode: efs.PerformanceMode.GENERAL_PURPOSE,
      throughputMode: efs.ThroughputMode.BURSTING,
      encrypted: true,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    // Do not open EFS broadly; we'll allow only the ECS service SG later

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

    // Create EFS access point and add EFS volume to task definition with IAM authorization
    const accessPoint = fileSystem.addAccessPoint('GrafanaAccessPoint', {
      path: '/grafana',
      createAcl: {
        ownerGid: '472',
        ownerUid: '472',
        permissions: '755',
      },
      posixUser: {
        gid: '472',
        uid: '472',
      },
    });

    taskDefinition.addVolume({
      name: 'grafana-storage',
      efsVolumeConfiguration: {
        fileSystemId: fileSystem.fileSystemId,
        transitEncryption: 'ENABLED',
        authorizationConfig: {
          accessPointId: accessPoint.accessPointId,
          iam: 'ENABLED',
        },
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

    // Create ACM Certificate for HTTPS
    const certificate = new acm.Certificate(this, 'GrafanaCertificate', {
      domainName: 'logs.servers8.com',
      validation: acm.CertificateValidation.fromDns(), // DNS validation
    });

    // Create ECS Fargate Service (without patterns)
    const fargateService = new ecs.FargateService(this, 'GrafanaService', {
      cluster,
      taskDefinition,
      desiredCount: 1,
      assignPublicIp: true,
    });

    // Restrict EFS to the service's security group
    fileSystem.connections.allowFrom(fargateService, ec2.Port.tcp(2049), 'Allow NFS from ECS service');

    // Create Application Load Balancer (HTTPS only)
    const alb = new elbv2.ApplicationLoadBalancer(this, 'GrafanaALB', {
      vpc,
      internetFacing: true,
    });

    const httpsListener = alb.addListener('HttpsListener', {
      port: 443,
      certificates: [certificate],
      protocol: elbv2.ApplicationProtocol.HTTPS,
      open: true,
    });

    // Forward to ECS service on container port 3000 with health check
    httpsListener.addTargets('GrafanaTargets', {
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

    // Allow ECS to connect outbound to EFS (NFS)
    fargateService.connections.allowTo(fileSystem, ec2.Port.tcp(2049), 'Allow EFS access');

    // Grant the task role EFS client permissions when IAM auth is enabled
    fileSystem.grant(fargateService.taskDefinition.taskRole, 'elasticfilesystem:ClientMount');
    fileSystem.grant(fargateService.taskDefinition.taskRole, 'elasticfilesystem:ClientWrite');

    // Output the Load Balancer URL
    new cdk.CfnOutput(this, 'GrafanaUrl', {
      value: `https://${alb.loadBalancerDnsName}`,
      description: 'Grafana URL',
    });

    // Output default credentials
    new cdk.CfnOutput(this, 'DefaultCredentials', {
      value: 'Username: admin, Password: admin',
      description: 'Default Grafana credentials',
    });
  }
}