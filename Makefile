RUNTESTS ?= runconfig-tests testpatt rollup envvars rerunclean listruns-tests itemwait dependencies testpatt_envvar toprun fullrun itemmap test2 chained-waiton
# NOT READY:  nested_mt
ITER ?= a
RUNNAME ?= $(shell date +ww%U.%u$(ITER))
BRANCH  =  $(shell (cd ..;fossil branch)|grep '*'|awk '{print $$2}')
ITER = w$(shell date +%U.%u)-$(shell (cd ..;fossil info)|grep checkout|awk '{print $$2}'|sed 's/^\(....\).*/\1/')
TARGET ?= $(BRANCH)/$(ITER)
NORMTESTPATT = toprun,testpatt_envvar,testpatt,runconfig-tests,rollup,rerunclean,listruns-tests,itemwait,envvars,dependencies,fullrun
EXTENDEDPATT = $(NORMTESTPATT),test2,ro_test,itemmap,chained-waiton

all :  onerun

slowsafe : runs
	for testname in $(RUNTESTS); do \
           megatest -run -target $(TARGET) -runname $(RUNNAME) -log logs/$(RUNNAME)_$$testname.log -run-wait -testpatt $$testname -generate-html ; \
	done

runinteg :
	flock --nonblock --verbose run-one.lock ./scripts/run-one-branch.sh

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
	megatest -run -target $(TARGET) -runname $(RUNNAME) -testpatt $(EXTENDEDPATT) -log logs/$(RUNNAME).log -run-wait -rerun-all -generate-html

clean :
	rm logs/*
