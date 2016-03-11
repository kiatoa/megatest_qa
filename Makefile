RUNTESTS ?= runconfig-tests testpatt rollup rerunclean listruns-tests itemwait dependencies testpatt_envvar toprun fullrun itemmap test2 chained-waiton nested_mt
all : 
	for testname in $(RUNTESTS); do \
            megatest -run -target $(TARGET) -runname $(RUNNAME) -testpatt $$testname ; \
	done

# -run-wait; \

dashboard :
	dashboard -rows 24 &

runs :
	mkdir -p runs

lntc : 
	mkdir lntc
	for x in $(shell ls tests);do ln -s $(PWD)/tests/$$x/testconfig $(PWD)/lntc/$$x;done
