RUNTESTS ?= runconfig-tests testpatt rollup envvars rerunclean listruns-tests itemwait dependencies testpatt_envvar toprun fullrun itemmap test2 chained-waiton,tconfdisks



# NOT READY:  nested_mt
RUNITER ?= a
RUNNAME ?= $(shell date +ww%U.%u$(RUNITER))
BRANCH  =  $(shell (cd ..;fossil branch)|grep '*'|awk '{print $$2}')
ITER    =  $(shell (cd ..;fossil info)|grep checkout|awk '{print $$2}'|sed 's/^\(....\).*/\1/')
TS_MODE ?= dev
TARGET  ?= $(BRANCH)/$(ITER)/$(TS_MODE)
NORMTESTPATT = toprun,testpatt_envvar,testpatt,runconfig-tests,rollup,rerunclean,listruns-tests,itemwait,envvars,dependencies,fullrun
EXTENDEDPATT = $(NORMTESTPATT),test2,ro_test,itemmap,chained-waiton

# note - GOODTESTS definition moved to runconfigs.config

# Templates are separate testsuites stored under the megatest_qa repo for use as DUTs in the megatest functional testsuite
#
TEMPLATES=chained-waiton dep-tests dynamic-waiton-example envvars fslsync fullrun installall itemmap itemmap2 listruns-tests mintest nested_mt rerunclean runconfig-tests simplerun speedtest

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

onerun: logs runs
	viewscreen "tail -F logs/$(RUNNAME).log"
	megatest -run -target $(TARGET) -runname $(RUNNAME) -testpatt goodtests  -log logs/$(RUNNAME).log -run-wait -rerun-all -generate-html

clean :
	rm logs/*


###############################
# Adding targets to debug rpc - bjbarcla

HOMEHOST_FILES=$(foreach dir,$(TEMPLATES),$(dir)/.homehost)
set-homehosts: $(HOMEHOST_FILES)
	@echo homehostfiles are setup

del-homehosts:
	rm -f .homehost $(HOMEHOST_FILES)

.homehost:
	host `hostname` | sed 's/^.* has address //' > .homehost

%/.homehost : .homehost
	cp .homehost $@



killem:
	-killall -v -9 mtest dboard

killem-hh:
	@if [[ ! -e .homehost ]]; then echo "no homehost"; /bin/false; else /bin/true; fi
	-ssh `cat .homehost` "make -C $(PWD) killem"

nocache: killem
	-rm -rf /tmp/$(USER)/megatest_localdb

nocache-hh: killem-hh
	@if [[ ! -e .homehost ]]; then echo "no homehost"; /bin/false; else /bin/true; fi
	-ssh `cat .homehost` "make -C $(PWD) nocache"

reset: nocache nocache-hh
	-chmod -R u+w runs links megatest.db
	-rm -rf runs links megatest.db
	-rm -rf /tmp/$(USER)/megatest_localdb
	-mkdir runs links
	-rm -rf logs/* .starting-server .server

watch-tcp:
	watch "make check-tcp check-tcp-hh"

check-tcp:
	@echo "This host: "`hostname`
	@echo
	@echo "COUNT,PID of mtest procs with CLOSE_WAIT status ports:"
	-@lsof 2>&1 | grep mtest | grep TCP | grep CLOSE_WAIT | awk '{print $$2}' | uniq -c
	@echo ""
	@echo "CWD of mtest procs with CLOSE_WAIT status ports"
	-@lsof 2>&1 |  grep mtest | grep TCP | grep CLOSE_WAIT | awk '{print $$2}' | uniq | awk '{print "ls -l /proc/"$$1"/cwd"}' > $@.$(HOSTNAME).tmp
	-@sh $@.$(HOSTNAME).tmp 2>/dev/null
	@echo ""
	@echo ""
	@rm -f $@.$(HOSTNAME).tmp

check-tcp-hh:
	@echo
	@echo
	@echo "HOMEHOST BELOW"
	@if [[ ! -e .homehost ]]; then echo "no homehost"; /bin/false; else /bin/true; fi
	-@ssh `cat .homehost` "make -C $(PWD) check-tcp"

srvlog:
	less +F logs/server.log 
