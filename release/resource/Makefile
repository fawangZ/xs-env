
ABS_WORK_DIR = $(shell pwd)
SRAM_FILELIST = $(ABS_WORK_DIR)/srams.f
CPU_FILELIST = $(ABS_WORK_DIR)/cpu.f

RTL_DIR =  rtl
SRAM_DIR = $(abspath ./$(RTL_DIR)/SRAM)
CPU_DIR = $(abspath ./$(RTL_DIR)/bosc_XSTop)
RUN_BIN_DIR = $(abspath ./bin)
REF_DIR = $(abspath ./ref)
SIM_DIR = $(abspath ./sim)

TRACE ?= 1
SPIKE ?= 0
REF =

RUN_OPTS := +workload=$(RUN_BIN_DIR)/$(RUN_BIN)
ifeq ($(TRACE),1)
	RUN_OPTS += +dump-wave=fsdb
endif
ifeq ($(SPIKE),1)
	REF=Spike
	RUN_OPTS += +diff=$(REF_DIR)/riscv64-spike-so
else
	RUN_OPTS += +diff=$(REF_DIR)/riscv64-nemu-interpreter-so
endif

RUN_OPTS += -fgp=num_threads:4,num_fsdb_threads:4
RUN_OPTS += -assert finish_maxfail=30 -assert global_finish_maxfail=10000

flist:
	$(shell find $(SRAM_DIR) -name "*.v" -or -name "*.sv" > $(SRAM_FILELIST))
	$(shell echo "-f $(SRAM_FILELIST)" > $(CPU_FILELIST))
	$(shell find $(CPU_DIR) -name "*.v" -or -name "*.sv" >> $(CPU_FILELIST))

simv:flist
	$(MAKE) -C ./env simv DUT_FILELIST=$(CPU_FILELIST) CONSIDER_FSDB=$(TRACE) VCS_SIM_DIR=$(SIM_DIR) REF=$(REF)
	rm cpu.f
	rm srams.f

run:
	$(shell if [ ! -e $(SIM_DIR)/$(RUN_BIN) ];then mkdir -p $(SIM_DIR)/$(RUN_BIN); fi)
	touch $(SIM_DIR)/$(RUN_BIN)/sim.log
	$(shell if [ -e $(SIM_DIR)/$(RUN_BIN)/simv ];then rm -f $(SIM_DIR)/$(RUN_BIN)/simv; fi)
	$(shell if [ -e $(SIM_DIR)/$(RUN_BIN)/simv.daidir ];then rm -rf $(SIM_DIR)/$(RUN_BIN)/simv.daidir; fi)
	ln -s $(SIM_DIR)/comp/simv $(SIM_DIR)/$(RUN_BIN)/simv
	ln -s $(SIM_DIR)/comp/simv.daidir $(SIM_DIR)/$(RUN_BIN)/simv.daidir
	cd $(SIM_DIR)/$(RUN_BIN) && (./simv $(RUN_OPTS) 2> assert.log | tee sim.log)

verdi:
	cd $(SIM_DIR)/$(RUN_BIN) && verdi -sv -2001 +verilog2001ext+v +systemverilogext+v -ssf tb_top.vf -dbdir simv.daidir -f sim_flist.f

clean:
	rm -rf sim/*
	touch cpu.f
	touch srams.f
	rm cpu.f
	rm srams.f
