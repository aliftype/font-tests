.PHONY: all check

PY?=python3

TESTSDIR=tests
LOGSDIR=logs
REFDIR=references

RUNTEST=runtest.py

TESTS=$(sort $(wildcard $(TESTSDIR)/*.txt))

AMLOGS=$(TESTS:$(TESTSDIR)/%.txt=$(LOGSDIR)/amiri/%.log)
ARLOGS=$(TESTS:$(TESTSDIR)/%.txt=$(LOGSDIR)/aref-ruqaa/%.log)

all: check

check: $(AMLOGS) $(ARLOGS)

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
