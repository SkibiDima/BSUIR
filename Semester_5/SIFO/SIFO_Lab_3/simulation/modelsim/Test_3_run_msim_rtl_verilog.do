transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/dimuki_ken/Quartus/Projects/SIFO_Lab_3/src {/home/dimuki_ken/Quartus/Projects/SIFO_Lab_3/src/all_blocks.v}

vlog -vlog01compat -work work +incdir+/home/dimuki_ken/Quartus/Projects/SIFO_Lab_3/src_testbenches {/home/dimuki_ken/Quartus/Projects/SIFO_Lab_3/src_testbenches/all_blocks_testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  all_blocks_testbench

add wave *
view structure
view signals
run -all
