#!/usr/bin/env python

from __future__ import print_function
import boto3
import json
import sys


def main():
    policy_name = json.loads(sys.stdin.readline())['policy_name']
    scaling_policy = boto3.client('autoscaling').describe_policies(PolicyNames=[policy_name])
    print(json.dumps({'policy_arn': scaling_policy['ScalingPolicies'][0]['PolicyARN']}))


if __name__ == '__main__':
    main()
