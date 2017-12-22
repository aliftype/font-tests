.PHONY: all check

PY?=python3

TESTSDIR=tests
LOGSDIR=logs
REFDIR=references

RUNTEST=runtest.py

AMREFS=$(sort $(wildcard $(REFDIR)/amiri/*.ref))
AQREFS=$(sort $(wildcard $(REFDIR)/amiri-quran/*.ref))
ARREFS=$(sort $(wildcard $(REFDIR)/aref-ruqaa/*.ref))

AMLOGS=$(AMREFS:$(REFDIR)/amiri/%.ref=$(LOGSDIR)/amiri/%.log)
AQLOGS=$(AQREFS:$(REFDIR)/amiri-quran/%.ref=$(LOGSDIR)/amiri-quran/%.log)
ARLOGS=$(ARREFS:$(REFDIR)/aref-ruqaa/%.ref=$(LOGSDIR)/aref-ruqaa/%.log)

all: amiri aref-ruqaa

amiri: $(AMLOGS)
amiri-quran: $(AQLOGS)
aref-ruqaa: $(ARLOGS)

%.log: FORCE
	@$(eval REF=$(notdir $(patsubst %/,%,$(dir $@))))
	@$(eval TEST=$(basename $(notdir $@)))
	@echo "   TEST    $(REF):$(TEST)"
	@mkdir -p $(dir $@)
	@$(PY) $(RUNTEST)                                                      \
	       --font-file=$(REFDIR)/$(REF)/font                      \
	       --test-file=$(TESTSDIR)/$(TEST).txt                             \
	       --ref-file=$(REFDIR)/$(REF)/$(TEST).ref                \
	       --log-file=$@

FORCE:
