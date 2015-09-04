all : 
	for testname in testpatt rollup itemwait itemmap dependencies testpatt_envvar toprun fullrun test2 ; do \
            megatest -run -target $(TARGET) -runname $(RUNNAME) -testpatt $$testname -run-wait; \
	done

dashboard :
	dashboard -rows 24 &

runs :
	mkdir -p runs
