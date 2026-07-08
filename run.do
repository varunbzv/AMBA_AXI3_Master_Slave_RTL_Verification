# run.do - QuestaSim Simulation
# Set paths
set SRC_DIR "../src"
set SIM_DIR "../simulation"

# Clean and create work library safely
if {[file exists work]} {
    vdel -all
}
vlib work
vmap work work

# Compile design files
vlog +define+SIM $SRC_DIR/defines/define.sv

vlog +incdir+$SRC_DIR/axi \
     $SRC_DIR/axi/axi_master.sv \
     $SRC_DIR/axi/axi_master_wr.sv \
     $SRC_DIR/axi/axi_master_rd.sv \
     $SRC_DIR/axi/axi_slave.sv

# Compile Testbench

vlog +incdir+$SRC_DIR/axi +incdir+$SRC_DIR/defines \
     $SIM_DIR/axi_tb.sv

# Launch Simulation
vsim -voptargs=+acc work.axi_tb 
add wave -r *

run -all
