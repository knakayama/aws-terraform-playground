resource "aws_ssm_document" "ssm1" {
  name          = "test_document1"
  document_type = "Command"

  content = <<EOT
{
   "schemaVersion":"2.0",
   "description":"Run a script",
   "parameters": {
      "commands": {
         "type": "StringList",
         "description": "(Required) Specify a shell script or a command to run.",
         "minItems": 1,
         "displayType": "textarea"
      }
   },
   "mainSteps": [
      {
         "action": "aws:runShellScript",
         "name": "runShellScript",
         "inputs": {
            "commands": "{{ commands }}"
         }
      }
   ]
}
EOT
}

resource "aws_ssm_document" "ssm2" {
  name          = "test_document2"
  document_type = "Command"

  content = <<EOT
{
    "schemaVersion":"1.2",
    "description":"Run a shell script or specify the path to a script to run.",
    "parameters":{
        "commands":{
            "type":"StringList",
            "description":"(Required) Specify the commands to run or the paths to existing scripts on the instance.",
            "minItems":1,
            "displayType":"textarea"
        },
        "workingDirectory":{
            "type":"String",
            "default":"",
            "description":"(Optional) The path to the working directory on your instance.",
            "maxChars":4096
        },
        "executionTimeout":{
            "type":"String",
            "default":"3600",
            "description":"(Optional) The time in seconds for a command to be completed before it is considered to have failed. Default is 3600 (1 hour). Maximum is 28800 (8 hours).",
            "allowedPattern":"([1-9][0-9]{0,3})|(1[0-9]{1,4})|(2[0-7][0-9]{1,3})|(28[0-7][0-9]{1,2})|(28800)"
        }
    },
    "runtimeConfig":{
        "aws:runShellScript":{
            "properties":[
                {
                    "id":"0.aws:runShellScript",
                    "runCommand":"{{ commands }}",
                    "workingDirectory":"{{ workingDirectory }}",
                    "timeoutSeconds":"{{ executionTimeout }}"
                }
            ]
        }
    }
}
EOT
}
