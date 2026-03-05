
#if {[file exists work]} {
   #vdel -all --> has a chance to fail if the directory is corrupted 
#   file delete -force work 
#}
#vlib work 

#vcom -2008 ./TPUFiles/*.vhd

#compiling the package 
#vcom -2008 types_package.vhd 


vcom -2008 invg.vhd
vcom -2008 andg2.vhd
vcom -2008 org2.vhd
vcom -2008 xorg2.vhd
vcom -2008 mux2t1.vhd
vcom -2008 mux2t1_N.vhd
vcom -2008 full_adder.vhd
vcom -2008 ripple_carry_adderN.vhd
vcom -2008 fetch_unit_sandbox.vhd
vcom -2008 tb_fetch_unit_sandbox.vhd

## --- UNCOMMENT THIS IF YOU WANT TO SANDBOX TEST THE FETCH UNIT --- ##
vsim -voptargs="+acc" work.tb_fetch_unit_sandbox


add wave -radix hex sim:/tb_fetch_unit_sandbox/*



run 1000

echo "project one sandbox -- COMPILED!" 