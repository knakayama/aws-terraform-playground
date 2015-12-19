{
  "Resources": {
    "myDistribution": {
      "Type": "AWS::CloudFront::Distribution",
      "Properties": {
        "DistributionConfig": {
          "Origins": [
            {
              "DomainName": "${domain_name}",
              "Id": "${id}",
              "CustomOriginConfig": {
                "HTTPPort": "80",
                "HTTPSPort": "443",
                "OriginProtocolPolicy": "http-only"
              }
            }
          ],
          "Enabled": "true",
          "DefaultRootObject": "index.html",
          "Aliases": [
            "${website_endpoint}"
          ],
          "DefaultCacheBehavior": {
            "AllowedMethods": ["GET", "HEAD"],
            "TargetOriginId": "${id}",
            "SmoothStreaming": "false",
            "ForwardedValues": {
              "QueryString": "false",
              "Cookies": { "Forward": "false" }
            },
            "ViewerProtocolPolicy": "allow-all",
          },
          "PriceClass": "PriceClass_All"
        }
      }
    }
  }
}
