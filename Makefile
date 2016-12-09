RUNTESTS ?= runconfig-tests testpatt rollup envvars rerunclean listruns-tests itemwait dependencies testpatt_envvar toprun fullrun itemmap test2 chained-waiton
GOODTESTS = runconfig-tests,testpatt,rollup,envvars,rerunclean,listruns-tests,itemwait,dependencies,testpatt_envvar,toprun,fullrun,ro_test 

# NOT READY:  nested_mt
ITER ?= a
RUNNAME ?= $(shell date +ww%U.%u$(ITER))
TARGET ?= $(shell (cd ..;fossil branch)|grep '*'|awk '{print $$2}')/$(shell (cd ..;fossil info)|grep checkout|awk '{print $$2}'|sed 's/^\(....\).*/\1/')

TEMPLATES=chained-waiton dep-tests dynamic-waiton-example envvars fslsync fullrun installall itemmap itemmap2 listruns-tests mintest nested_mt rerunclean runconfig-tests simplerun speedtest

HOMEHOST_FILES=$(foreach dir,$(TEMPLATES),$(dir)/.homehost)




all :  onerun

set-homehosts: $(HOMEHOST_FILES)
	@echo homehostfiles are setup

del-homehosts:
	rm -f .homehost $(HOMEHOST_FILES)

.homehost:
	host `hostname` | sed 's/^.* has address //' > .homehost

%/.homehost : .homehost
	cp .homehost $@


slowsafe : runs
	for testname in $(RUNTESTS); do \
           megatest -run -target $(TARGET) -runname $(RUNNAME) -log logs/$(RUNNAME)_$$testname.log -run-wait -testpatt $$testname -generate-html ; \
	done

# -run-wait; \

dashboard : runs logs
	dashboard -rows 20 &

runs :
	mkdir -p runs

logs :
	mkdir -p logs

logs/$(RUNNAME) : logs
	mkdir -p logs/$(RUNNAME)

lntc : 
	mkdir lntc
	for x in $(shell ls tests);do ln -s $(PWD)/tests/$$x/testconfig $(PWD)/lntc/$$x;done

# Use this target for -j

logs/$(RUNNAME)/%.log : logs/$(RUNNAME) tests/%/testconfig
	megatest -run -target $(TARGET) -runname $(RUNNAME) -testpatt $(*F) -log logs/$(RUNNAME)/$(*F).log

#	megatest -run -target $(TARGET) -runname $(RUNNAME) -testpatt $(*F) > logs/$(RUNNAME)/$(*F).log 2>&1

LOGS=$(addprefix logs/$(RUNNAME)/,$(addsuffix .log,$(RUNTESTS)))

parallel : logs $(LOGS)

onerun : logs runs
	viewscreen "tail -F logs/$(RUNNAME).log"
	megatest -run -target $(TARGET) -runname $(RUNNAME) -testpatt $(GOODTESTS) -log logs/$(RUNNAME).log -run-wait -rerun-all -generate-html

clean :
	rm logs/*
