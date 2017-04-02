
dashboard:
	dashboard -rows 25 &

run:
	megatest -run -testpatt % -target SYSTEM_val/RELEASE_val -runname go -clean-cache


reset:
	./kill_megatests_in_toppath
	rm -rf runarea/SYSTEM_val
	rm -rf links/SYSTEM_val
	rm -rf megatest.db
	rm -rf lt/.db
	rm -rf lt
	rm -rf /tmp/$(USER)/megatest_localdb/epra/`readlink -f . | tr "/" "."`/*
	rm -rf logs
	mkdir logs
