# ------------------------------------------------------------------------------
# release config
# ------------------------------------------------------------------------------

RELEASE_NEMU_CONFIG=riscv64-xs-nh3

RELEASE_DATE = $(shell date +"%Y%m%d")

TEMP_PATH=./temp
RELEASE_PATH=./release_$(RELEASE_DATE)
RELEASE_REF_PATH=$(RELEASE_PATH)/ref
RELEASE_BIN_PATH=$(RELEASE_PATH)/bin
RELEASE_ENV_PATH=$(RELEASE_PATH)/env
RELEASE_DIFFTEST_PATH=$(RELEASE_PATH)/env/difftest
RELEASE_SIM_NEMU_PATH=$(RELEASE_PATH)/sim_nemu
RELEASE_SIM_SPIKE_PATH=$(RELEASE_PATH)/sim_spike

# ------------------------------------------------------------------------------
# 0 release
# ------------------------------------------------------------------------------

release:
	make misc-release -j5
	make rtl-release -j2

misc-release: release-nemu release-spike release-case release-difftest release-resources

$(TEMP_PATH):
	mkdir -p $(TEMP_PATH)

$(RELEASE_PATH):
	mkdir -p $(RELEASE_PATH)

$(RELEASE_REF_PATH):
	mkdir -p $(RELEASE_REF_PATH)

$(RELEASE_BIN_PATH):
	mkdir -p $(RELEASE_BIN_PATH)

$(RELEASE_ENV_PATH):
	mkdir -p $(RELEASE_ENV_PATH)

$(RELEASE_DIFFTEST_PATH):
	mkdir -p $(RELEASE_DIFFTEST_PATH)

$(RELEASE_SIM_NEMU_PATH):
	mkdir -p $(RELEASE_SIM_NEMU_PATH)

$(RELEASE_SIM_SPIKE_PATH):
	mkdir -p $(RELEASE_SIM_SPIKE_PATH)

# ------------------------------------------------------------------------------
# 1 release rtl
# ------------------------------------------------------------------------------

PREFIX = bosc_

rtl-release: release-simrtl release-rtl

release-xstop: $(RELEASE_PATH)
	$(MAKE) -C $(NOOP_HOME) verilog VCS=1 NUM_CORES=4 PREFIX=$(PREFIX)
	python3 scripts/parser.py XSTop --prefix=bosc_ --build-dir=$(NOOP_HOME)/build
	sed -i '/assign _core_with_l2_1_reset/i\  wire reset_othercores = 1'"'"'b0;\n  wire clock_enable = 1'"'"'b1;' $(PREFIX)XSTop/$(PREFIX)XSTop/$(PREFIX)XSTop.sv
	sed -i 's/_core_with_l2_[123]_reset =/& reset_othercores \|/' $(PREFIX)XSTop/$(PREFIX)XSTop/$(PREFIX)XSTop.sv
	sed -i '/XSTile core_with_l2_/{n;s/(io_clock/& \& clock_enable/;}' $(PREFIX)XSTop/$(PREFIX)XSTop/$(PREFIX)XSTop.sv
	rm -rf $(RELEASE_PATH)/XSTop
	mv -f $(PREFIX)XSTop $(RELEASE_PATH)/rtl

release-rtl: $(TEMP_PATH)
	cp -r $(NOOP_HOME) $(TEMP_PATH)/_rtl_build
	$(MAKE) release-xstop NOOP_HOME=$(abspath $(TEMP_PATH)/_rtl_build)

release-simtop: $(RELEASE_ENV_PATH)
	$(MAKE) -C $(NOOP_HOME) sim-verilog VCS=1 NUM_CORES=4
	find $(NOOP_HOME)/difftest/src/test/vsrc/common -name "*.v" |xargs -n1 cat >> $(NOOP_HOME)/build/SimTop.sv
	python3 scripts/parser.py SimTop --ignore XSTop --build-dir=$(NOOP_HOME)/build
	sed -i 's/XSTop l_soc/bosc_&/' SimTop/SimTop/SimTop.sv
	rm SimTop/SimTop/RAMHelper.sv
	rm -rf $(RELEASE_ENV_PATH)/SimTop
	mv -f SimTop/SimTop $(RELEASE_ENV_PATH)

release-simrtl: $(TEMP_PATH)
	cp -r $(NOOP_HOME) $(TEMP_PATH)/_simrtl_build
	$(MAKE) release-simtop NOOP_HOME=$(abspath $(TEMP_PATH)/_simrtl_build)
	
# ------------------------------------------------------------------------------
# 2 release REF model
# ------------------------------------------------------------------------------

release-nemu: $(RELEASE_REF_PATH) $(RELEASE_PATH)
	$(MAKE) -C $(NEMU_HOME) clean-all
	cp -r $(NEMU_HOME) $(RELEASE_PATH)
	$(MAKE) -C $(NEMU_HOME) $(RELEASE_NEMU_CONFIG)-ref_defconfig
	$(MAKE) -C $(NEMU_HOME) -j
	cp $(NEMU_HOME)/build/riscv64-nemu-interpreter-so $(RELEASE_REF_PATH)

release-spike: $(RELEASE_REF_PATH) $(RELEASE_PATH)
	$(MAKE) -C $(SPIKE_HOME)/difftest clean
	cp -r $(SPIKE_HOME) $(RELEASE_PATH)
	$(MAKE) -C $(SPIKE_HOME)/difftest -j
	cp $(SPIKE_HOME)/difftest/build/riscv64-spike-so $(RELEASE_REF_PATH)

# ------------------------------------------------------------------------------
# 3 release case and am
# ------------------------------------------------------------------------------

CASES = coremark microbench dhrystone whetstone stream hello
ARCH = riscv64-xs-nhv3

release-case: $(RELEASE_BIN_PATH)
	$(MAKE) -C $(AM_HOME) clean
	cp -r $(AM_HOME) $(RELEASE_PATH)
	@$(foreach CASE, $(CASES), \
		$(MAKE) -C $(AM_HOME)/apps/$(CASE) ARCH=$(ARCH); \
		cp $(AM_HOME)/apps/$(CASE)/build/$(CASE)-$(ARCH).bin $(RELEASE_BIN_PATH)/$(CASE).bin; \
	)

# ------------------------------------------------------------------------------
# 4 release difftest
# ------------------------------------------------------------------------------

release-difftest: $(RELEASE_DIFFTEST_PATH)
	cp -r $(DIFF_HOME)/config $(RELEASE_DIFFTEST_PATH)
	cp -r $(DIFF_HOME)/src $(RELEASE_DIFFTEST_PATH)
	sed -i '/endmodule/i\initial begin\n  force sim.l_soc.reset_othercores = 1'"'"'b1;\n  #50;\n  force sim.l_soc.clock_enable = 1'"'"'b0;\nend' $(RELEASE_DIFFTEST_PATH)/src/test/vsrc/vcs/top.v

# ------------------------------------------------------------------------------
# 5 release resource
# ------------------------------------------------------------------------------

release-resources: $(RELEASE_PATH) $(RELEASE_BIN_PATH) $(RELEASE_ENV_PATH)
	cp resource/Makefile resource/README.md $(RELEASE_PATH)
	cp resource/makefile resource/vcs.mk $(RELEASE_ENV_PATH)
	cp resource/linux.bin $(RELEASE_BIN_PATH)

# ------------------------------------------------------------------------------
# 6 regression
# ------------------------------------------------------------------------------

regression-nemu: $(RELEASE_SIM_NEMU_PATH)
	make simv -C $(RELEASE_PATH) SIM_DIR=$(abspath $(RELEASE_SIM_NEMU_PATH))
	make run  -C $(RELEASE_PATH) SIM_DIR=$(abspath $(RELEASE_SIM_NEMU_PATH)) RUN_BIN=hello.bin

regression-spike: $(RELEASE_SIM_SPIKE_PATH)
	make simv -C $(RELEASE_PATH) SPIKE=1 SIM_DIR=$(abspath $(RELEASE_SIM_SPIKE_PATH))
	make run  -C $(RELEASE_PATH) SPIKE=1 SIM_DIR=$(abspath $(RELEASE_SIM_SPIKE_PATH)) RUN_BIN=hello.bin

regression: release
	make regression-nemu
	make regression-spike
	find $(RELEASE_PATH) -name "sim.log" | xargs -n1 grep "TRAP"

package: $(RELEASE_PATH)
	make clean -C $(RELEASE_PATH)
	tar zcpf $(RELEASE_PATH).tar.gz $(RELEASE_PATH)

clean:
	rm release_* -rf
	rm temp -rf
	rm SimTop -rf

.PHONY: clean release regression package
.DEFAULT: release