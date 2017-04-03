
LANG ?= ru

all:
	export PYTHONDONTWRITEBYTECODE=yes

i18n:
	mkdir --parents languages/$(LANG)/LC_MESSAGES
	msgfmt languages/$(LANG).po --statistics --output-file=languages/$(LANG)/LC_MESSAGES/ipxact.mo

