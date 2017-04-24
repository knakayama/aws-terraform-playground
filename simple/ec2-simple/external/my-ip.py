#!/usr/bin/env python

import requests
import json


def main():
    ip = requests.get('https://ifconfig.co/json').json()['ip']
    print(json.dumps({'ip': ip + '/32'}))


if __name__ == '__main__':
    main()
