RUNTESTS ?= runconfig-tests testpatt rollup rerunclean listruns-tests itemwait dependencies testpatt_envvar toprun fullrun itemmap test2 chained-waiton
# NOT READY:  nested_mt
ITER ?= a
RUNNAME ?= $(shell date +ww%U.%u$(ITER))
TARGET ?= $(shell (cd ..;fossil branch)|grep '*'|awk '{print $$2}')/$(shell (cd ..;fossil info)|grep checkout|awk '{print $$2}'|sed 's/^\(....\).*/\1/')

all : 
	for testname in $(RUNTESTS); do \
            megatest -run -target $(TARGET) -runname $(RUNNAME) -testpatt $$testname ; \
	done

# -run-wait; \

dashboard : runs logs
	dashboard -rows 24 &

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
	megatest -run -target $(TARGET) -runname $(RUNNAME) -testpatt $(*F) > logs/$(RUNNAME)/$(*F).log 2>&1

LOGS=$(addprefix logs/$(RUNNAME)/,$(addsuffix .log,$(RUNTESTS)))

parallel : logs $(LOGS)

clean :
	rm logs/*
