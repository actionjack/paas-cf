#!/usr/bin/env python
import argparse
import boto3
import netaddr

class ElasticacheBrokerTest(object):
    def __init__(self, vpc_id, instance_id, service_id, plan_id, security_group_id, org_id=None, space_id=None):
        self.instance_id = instance_id
        self.service_id = service_id
        self.plan_id = plan_id
        self.org_id = org_id
        self.space_id = space_id
        self.security_group_id = security_group_id

    def provision(self):
        elasticache = boto3.client('elasticache')
        vpc = boto3.resource('ec2').Vpc(self.vpc_id)

        subnets = self.create_subnets(vpc, select_subnets())

        subnet_group = self.create_subnet_group(elasticache, subnets)
        self.create_elasticache(elasticache, subnet_group, self.cache_node_type(self.plan_id), self.engine_version())

    def deprovision(self):
        print self

    def select_subnets(self):
        supernet = netaddr.IPNetwork('10.0.64.0/18')
        all_subnets = list(supernet.subnet(28))
        # TODO
        # used_subnets = [] # derive from aws
        # return (all_subnets - used_subnets).take(2)
        azs = ['eu-west-1a', 'eu-west-1b']
        return zip(all_subnets[:2], azs)

    def create_subnets(self, vpc, subnets_and_azs):
        return map(lambda (subnet, az):
                vpc.create_subnet(
                    DryRun=False,
                    CidrBlock=subnet,
                    AvailabilityZone=az
                ).subnet_id,
            subnets_and_azs
        )

    def create_subnet_group(self, elasticache, subnets):
        return elasticache.create_cache_subnet_group(
            CacheSubnetGroupName='cache-subnet-group-%s' % self.instance_id,
            CacheSubnetGroupDescription='Cache subnet group for %s' % self.instance_id,
            SubnetIds=subnets
        )['CacheSubnetGroup']['CacheSubnetGroupName']

    def create_elasticache(self, elasticache, subnet_group, cache_node_type, engine_version):
        # http://boto3.readthedocs.io/en/latest/reference/services/elasticache.html#ElastiCache.Client.create_cache_cluster
        return elasticache.create_cache_cluster(
            CacheClusterId='cache-cluster-%s' % self.instance_id,
            #ReplicationGroupId='string',
            NumCacheNodes=1,
            CacheNodeType=cache_node_type,
            Engine='redis',
            EngineVersion=engine_version,
            # CacheParameterGroupName='string',
            CacheSubnetGroupName=subnet_group,
            #NOTE: the broker would get security group from manifest
            SecurityGroupIds=[
                self.security_group_id,
            ],
            Tags=[
                {
                    'Key': 'Owner',
                    'Value': 'Cloud Foundry'
                },
                {
                    'Key': 'Plan ID',
                    'Value': self.plan_id
                },
                {
                    'Key': 'Service ID',
                    'Value': self.service_id
                },
                {
                    'Key': 'Space ID',
                    'Value': self.space_id
                },
                {
                    'Key': 'Broker Name',
                    'Value': 'Insert some env-specific name here'
                },
                {
                    'Key': 'Organization ID',
                    'Value': self.org_id
                },
            ],
            #SnapshotArns=[],
            #SnapshotName='string',
            PreferredMaintenanceWindow='Thu:03:00-Thu:04:00',
            Port=6379,
            #NotificationTopicArn='string',
            AutoMinorVersionUpgrade=False,
            SnapshotRetentionLimit=7,
            SnapshotWindow='01:00-02:00',
            # For guidance on AuthToken see:
            # http://boto3.readthedocs.io/en/latest/reference/services/elasticache.html#ElastiCache.Client.create_cache_cluster
            AuthToken='string'
        )

    def cache_node_type(plan_id):
        #TODO: get the node type from the plan
        return 'cache.t2.micro'

    def engine_version():
        #TODO: get the engine version from the plan
        # http://docs.aws.amazon.com/AmazonElastiCache/latest/UserGuide/SelectEngine.RedisVersions.html
        return '3.2.4'


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    action_group = parser.add_mutually_exclusive_group(required=True)
    action_group.add_argument('--provision', help='Create a new elasticache', action='store_true')
    action_group.add_argument('--deprovision', help='Delete an existing elasticache', action='store_true')

    parser.add_argument('--vpc-id', help='Id for existing VPC', required=True)
    parser.add_argument('--instance-id', help='Id for new elasticache instance', required=True)
    parser.add_argument('--service-id', help='Service ID for new elasticache instance', required=True)
    parser.add_argument('--plan-id', help='Plan ID for new elasticache instance', required=True)
    parser.add_argument('--org-id', help='Org for new elasticache instance', required=True)
    parser.add_argument('--space-id', help='Space for new elasticache instance', required=True)
    parser.add_argument('--security-group-id', help='Security group for new elasticache instance', required=True)

    args = parser.parse_args()

    ec = ElasticacheBrokerTest(args.vpc_id, args.instance_id, args.service_id, args.plan_id, args.security_group_id, args.org_id, args.space_id)
    if args.provision:
        ec.provision()
    else:
        ec.deprovision()
