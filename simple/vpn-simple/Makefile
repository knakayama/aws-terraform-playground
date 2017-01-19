default: tf

tf:
	@cd env/$(env) && terraform get && terraform $(args) -var-file=secrets.tfvars

.PHONY: tf
