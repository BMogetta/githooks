test:
	chmod +x commit-msg.sh && bats commit-msg_test.bats
test2:
	chmod +x commit-msg-2.sh && bats commit-msg_test.bats
PHONY: 
	test test2