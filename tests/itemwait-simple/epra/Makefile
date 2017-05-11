RUNNAME=go
TARGET=SYSTEM_val/RELEASE_val
TESTPATT=itemwait-second
help:
	echo "3 targets -- dashboard run reset"

dashboard:
	dashboard -rows 25 &

run:
	megatest -run -run-wait -testpatt $(TESTPATT) -target $(TARGET) -runname $(RUNNAME) -clean-cache
	echo "status"
	megatest -list-runs go | grep "skiptest-second" | grep Status


reset:
	./kill_megatests_in_toppath
	rm -rf runarea/$(TARGET)
	rm -rf links/$(TARGET)
	rm -rf megatest.db
	rm -rf lt
	rm -rf /tmp/$(USER)/megatest_localdb/epra/`readlink -f . | tr "/" "."`/*
	rm -rf logs
	rm -rf *.log
	rm -rf kickoff
	rm -rf .read* .home*
	mkdir logs
