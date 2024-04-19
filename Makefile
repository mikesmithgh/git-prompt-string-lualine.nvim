TESTS_INIT = tests/minimal_init.lua
# 30 mins
TIMEOUT_MINS := $(shell echo $$((30 * 60 * 1000)))

.PHONY: test
test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "lua require([[plenary.test_harness]]).test_directory([[tests]], { minimal_init = '"${TESTS_INIT}"', timeout = "${TIMEOUT_MINS}", })"

