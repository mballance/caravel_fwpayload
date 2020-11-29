
DV_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

TESTS := $(shell ls $(DV_DIR) | grep -v 'common' | grep -v 'bringup' | grep -v 'Makefile' | grep -v '.log')

all :
	for t in $(TESTS); do \
		echo "Running $${t}"; \
		$(MAKE) -C $$t > $${t}.log 2>&1; \
	done


clean :
	for t in $(TESTS); do \
		$(MAKE) -C $$t clean ; \
	done
