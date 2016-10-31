BUCKET_NAME = terraform-circleci-demo-tfstate
REGION = ap-northeast-1
CD = [ -d env/${ENV} ] && cd env/${ENV}
ENV = $1
ARGS = $2

terraform:
	@${CD} && \
		terraform ${ARGS}

remote-enable:
	@${CD} && \
		terraform remote config \
		-backend=s3 \
		-backend-config='bucket=${BUCKET_NAME}' \
		-backend-config='key=${ENV}/terraform.tfstate' \
		-backend-config='region=${REGION}'

remote-disable:
	@${CD} && \
		terraform remote config \
		-disable
