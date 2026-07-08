set SRC_DIR "../src"
set SIM_DIR "../simulation"
if {[file exists work]} {vdel -all}
vlib work
vmap work work
vlog +define+SIM $SRC_DIR/defines/define.sv
vlog +incdir+$SRC_DIR/axi \
     $SRC_DIR/axi/axi_master.sv \
     $SRC_DIR/axi/axi_master_wr.sv \
     $SRC_DIR/axi/axi_master_rd.sv \
     $SRC_DIR/axi/axi_slave.sv
vlog +incdir+$SRC_DIR/axi +incdir+$SRC_DIR/defines \
     $SIM_DIR/axi_tb.sv
vsim -voptargs=+acc work.axi_tb 
add wave -r *
run -all
