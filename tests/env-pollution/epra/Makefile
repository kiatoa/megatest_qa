RUNNAME=go
TARGET=SYSTEM_val/RELEASE_val

dashboard:
	dashboard -rows 25 &

run:
	./wait_kickoff $(TARGET) $(RUNNAME) test1/1 kickoff  &> kickoff.log &
	megatest -run -run-wait -testpatt % -target $(TARGET) -runname $(RUNNAME) -clean-cache


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
	mkdir logs
