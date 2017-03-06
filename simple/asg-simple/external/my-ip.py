#!/usr/bin/env python

from __future__ import print_function
import json
import urllib2


def main():
    ip = json.loads(urllib2.urlopen('https://ifconfig.co/json').read())['ip']
    print(json.dumps({'ip': ip + '/32'}))


if __name__ == '__main__':
    main()
