.PHONY: all check

PY?=python3

TESTSDIR=tests
LOGSDIR=logs
PROFILESDIR=profiles

RUNTEST=runtest.py

TESTS=$(sort $(wildcard $(TESTSDIR)/*.tst))

AMLOGS=$(TESTS:$(TESTSDIR)/%.tst=$(LOGSDIR)/amiri/%.log)
ARLOGS=$(TESTS:$(TESTSDIR)/%.tst=$(LOGSDIR)/aref-ruqaa/%.log)

all: check

check: $(AMLOGS) $(ARLOGS)

%.log: FORCE
	@$(eval PROFILE=$(notdir $(patsubst %/,%,$(dir $@))))
	@$(eval TEST=$(basename $(notdir $@)))
	@echo "   TEST    $(PROFILE):$(TEST)"
	@mkdir -p $(dir $@)
	@$(PY) $(RUNTEST)                                                      \
	       $(PROFILESDIR)/$(PROFILE)/font                                  \
	       $(TESTSDIR)/$(TEST).tst                                         \
	       $(PROFILESDIR)/$(PROFILE)/$(TEST).shp                           \
	       $@

FORCE:
