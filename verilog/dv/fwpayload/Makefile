
DV_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

TESTS += fwrisc_gpio fwrisc_gpio_la mgmt_mem_access mgmt_mem_access_la

verify : functional gatelevel

functional : 
	for t in $(TESTS); do \
		echo "Running $${t}"; \
		$(MAKE) -C $$t clean; \
		$(MAKE) -C $$t > $${t}.functional.log 2>&1; \
	done

gatelevel : 
	for t in $(TESTS); do \
		echo "Running $${t}"; \
		$(MAKE) -C $$t clean; \
		$(MAKE) -C $$t SIMTYPE=gate > $${t}.gatelevel.log 2>&1; \
	done


clean :
	for t in $(TESTS); do \
		$(MAKE) -C $$t clean ; \
	done

