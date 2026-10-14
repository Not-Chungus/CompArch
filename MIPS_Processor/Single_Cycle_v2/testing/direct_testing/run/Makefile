# ============================================================
# MIPS Single-Cycle Direct Testing
# ============================================================

TEST ?= ALL
SEED ?= 1

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------

IMPL_DIR = ../../../implementation
TB_DIR   = ../tb
TEST_DIR = ../tests/$(TEST)

TEST_MEM = $(TEST_DIR)/$(TEST).mem

# ------------------------------------------------------------
# Questa/ModelSim
# ------------------------------------------------------------

TOP = testbench

.PHONY: all compile run qrun clean help

all: run


# ============================================================
# Compile
# ============================================================

compile: clean
	@echo "========================================"
	@echo " Compiling MIPS Single-Cycle Processor"
	@echo " Test : $(TEST)"
	@echo " Mode : $(TEST)"
	@echo "========================================"

	vlib work

#should use a source.list 
	vlog -sv \
		$(IMPL_DIR)/*.sv \
		+incdir+$(IMPL_DIR) \
		$(TB_DIR)/tb.sv
		


# ============================================================
# Run in command line
# ============================================================

run: compile
	@echo "========================================"
	@echo " Running $(TEST)"
	@echo "========================================"

	vsim -c -voptargs=+acc work.$(TOP) \
		+TEST=$(TEST) \
		-sv_seed $(SEED) \
		-do "run -all; quit -f"


# ============================================================
# Run with GUI
# ============================================================

qrun: compile
	@echo "========================================"
	@echo " Running $(TEST) in Questa GUI"
	@echo "========================================"

	vsim -voptargs=+acc work.$(TOP) \
		+TEST=$(TEST) \
		-sv_seed $(SEED) \
		-do "do wave.do; run -all"

	


# ============================================================
# Clean
# ============================================================

clean:
	rm -rf work
	rm -f transcript
	rm -f vsim.wlf


# ============================================================
# Help
# ============================================================

help:
	@echo ""
	@echo "MIPS Single-Cycle Simulation"
	@echo ""
	@echo "Usage:"
	@echo "  make run TEST=Test1"
	@echo "  make run TEST=ALL (default)"
	@echo ""
	@echo "GUI:"
	@echo "  make qrun TEST=Test1"
	@echo "  make qrun TEST=ALL (default)"
	@echo ""