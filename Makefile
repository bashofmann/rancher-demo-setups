init:
	find .githooks -type f -exec ln -sf ../../{} .git/hooks/ \;

fix:
	terraform fmt -recursive

check:
	terraform fmt -recursive -check