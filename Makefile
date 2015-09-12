RUNTESTS ?= testpatt rollup rerunclean itemwait chained-waiton itemmap dependencies testpatt_envvar toprun fullrun test2
all : 
	for testname in $(RUNTESTS); do \
            megatest -run -target $(TARGET) -runname $(RUNNAME) -testpatt $$testname ; \
	done

# -run-wait; \

dashboard :
	dashboard -rows 24 &

runs :
	mkdir -p runs
