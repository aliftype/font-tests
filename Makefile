.PHONY: all check

PY?=python3

BASEDIR := $(dir $(lastword $(MAKEFILE_LIST)))

TESTSDIR=$(BASEDIR)/tests
LOGSDIR=$(BASEDIR)/logs
REFDIR=$(BASEDIR)/references
ENVDIR=$(BASEDIR)/env

RUNTEST=$(BASEDIR)/runtest.py

AMREFS=$(sort $(wildcard $(REFDIR)/amiri/*.ref))
AQREFS=$(sort $(wildcard $(REFDIR)/amiri-quran/*.ref))
ARREFS=$(sort $(wildcard $(REFDIR)/aref-ruqaa/*.ref))
QHREFS=$(sort $(wildcard $(REFDIR)/qahiri/*.ref))

AMLOGS=$(AMREFS:$(REFDIR)/amiri/%.ref=$(LOGSDIR)/amiri/%.log)
AQLOGS=$(AQREFS:$(REFDIR)/amiri-quran/%.ref=$(LOGSDIR)/amiri-quran/%.log)
ARLOGS=$(ARREFS:$(REFDIR)/aref-ruqaa/%.ref=$(LOGSDIR)/aref-ruqaa/%.log)
QHLOGS=$(QHREFS:$(REFDIR)/qahiri/%.ref=$(LOGSDIR)/qahiri/%.log)

all: amiri amiri-quran aref-ruqaa qahiri
update: update-amiri update-amiri-quran update-aref-ruqaa update-qahiri

amiri: $(AMLOGS)
amiri-quran: $(AQLOGS)
aref-ruqaa: $(ARLOGS)
qahiri: $(QHLOGS)

update-amiri: $(AMREFS)
update-amiri-quran: $(AQREFS)
update-aref-ruqaa: $(ARREFS)
update-qahiri: $(QHREFS)

.ONESHELL:

%.log: FORCE
	@source $(ENVDIR)/bin/activate
	@$(eval REF=$(notdir $(patsubst %/,%,$(dir $@))))
	@$(eval TEST=$(basename $(notdir $@)))
	@echo "   TEST    $(REF):$(TEST)"
	@mkdir -p $(dir $@)
	@$(PY) $(RUNTEST)                                                      \
	       --font-file=$(REFDIR)/$(REF)/font                               \
	       --test-file=$(TESTSDIR)/$(TEST).txt                             \
	       --ref-file=$(REFDIR)/$(REF)/$(TEST).ref                         \
	       --log-file=$@

%.ref: FORCE
	@source $(ENVDIR)/bin/activate
	@$(eval REF=$(notdir $(patsubst %/,%,$(dir $@))))
	@$(eval TEST=$(basename $(notdir $@)))
	@echo "   TEST    $(REF):$(TEST)"
	@$(PY) $(RUNTEST)                                                      \
	       --reference                                                     \
	       --font-file=$(REFDIR)/$(REF)/font                               \
	       --test-file=$(TESTSDIR)/$(TEST).txt                             \
	       --ref-file=$(REFDIR)/$(REF)/$(TEST).ref                         \
	       --log-file=$@

FORCE:
