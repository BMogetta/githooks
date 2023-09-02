test:
	chmod +x commit-msg.sh && bats commit-msg_test.bats
test2:
	chmod +x commit-msg.sh && bats short.bats

split:
	chmod +x split.bats && bats split.bats
PHONY: 
	test test2 split