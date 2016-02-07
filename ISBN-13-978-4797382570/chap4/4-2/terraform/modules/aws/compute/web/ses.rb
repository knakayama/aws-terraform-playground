#!/usr/bin/env ruby

require 'aws-sdk-core'

ses = Aws::SES::Client.new(
  region: 'ap-northeast-1'
)

resp = ses.send_email(
  source: 'from@example.com',
  destination: {
    to_addresses: ['to@example.com'],
  },
  message: {
    subject: {
      data: 'Test mail',
    },
    body: {
      text: {
        data: 'This is a test',
      },
    },
  },
)
