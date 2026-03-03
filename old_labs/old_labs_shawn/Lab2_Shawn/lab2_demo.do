quit -sim 

if {[file exists work]} {
   #vdel -all --> has a chance to fail if the directory is corrupted 
   file delete -force work 
}
vlib work 

#vcom -2008 ./TPUFiles/*.vhd

#compiling the package 
vcom -2008 types_package.vhd 



vcom -2008 ./Lab1Reused/andg2.vhd
vcom -2008 ./Lab1Reused/invg.vhd
vcom -2008 ./Lab1Reused/org2.vhd
vcom -2008 ./Lab1Reused/xorg2.vhd
vcom -2008 ./Lab1Reused/mux2t1.vhd
vcom -2008 ./Lab1Reused/mux2t1_N.vhd
vcom -2008 ./Lab1Reused/ones_comp.vhd
vcom -2008 ./Lab1Reused/full_adder.vhd
vcom -2008 ./Lab1Reused/ripple_carry_adderN.vhd
vcom -2008 ./Lab1Reused/adder_subtractorN.vhd





#compiling register stuff
vcom -2008 ./RegFile/dffg.vhd
vcom -2008 ./RegFile/tb_dffg.vhd 
vcom -2008 ./RegFile/register_NBit.vhd
vcom -2008 ./RegFile/tb_register_NBit.vhd

#compiling decoder 
vcom -2008 ./RegFile/decoder_5to32.vhd
vcom -2008 ./RegFile/tb_decoder_5to32.vhd

#compiling 32to1 mux 
vcom -2008 ./RegFile/mux_32to1.vhd
vcom -2008 ./RegFile/tb_mux_32to1.vhd

#compiling the register file
vcom -2008 ./RegFile/source_register.vhd
vcom -2008 ./RegFile/register_file.vhd
vcom -2008 ./RegFile/tb_register_file.vhd

#compiling the first datapath 
vcom -2008 ./MyFirstRISCVDatapath/first_datapath.vhd
vcom -2008 ./MyFirstRISCVDatapath/tb_first_datapath.vhd

#compiling the memory stuff
vcom -2008 ./Memory/mem.vhd
vcom -2008 tb_dmem.vhd

#compiling the bit extender 
vcom -2008 ./Extenders/bitextender_12to32.vhd
vcom -2008 ./Extenders/tb_bitextender_12to32.vhd


#compiling the second datapath 
vcom -2008 ./MySecondRISCVDatapath/second_datapath.vhd
#vcom -2008 ./MySecondRISCVDatapath/tb_second_datapath.vhd
vcom -2008 ./MySecondRISCVDatapath/tb2_second_datapath.vhd


#Starting Simulation 
vsim -voptargs="+acc" tb2_second_datapath

#fill all 1024 blocks with zeroes 
mem load -filltype value -filldata 0 /tb2_second_datapath/DUT/MEMORY_BLOCK/ram

#load real data now
mem load -infile dmem.hex -format hex /tb2_second_datapath/DUT/MEMORY_BLOCK/ram

examine -radix hex /tb2_second_datapath/DUT/MEMORY_BLOCK/ram(0)
examine -radix hex /tb2_second_datapath/DUT/MEMORY_BLOCK/ram(1)
examine -radix hex /tb2_second_datapath/DUT/MEMORY_BLOCK/ram(256)
examine -radix hex /tb2_second_datapath/DUT/MEMORY_BLOCK/ram(500)

add wave -radix hex sim:/tb2_second_datapath/*
add wave -radix hex /tb2_second_datapath/DUT/s_mem_output
add wave -radix hex /tb2_second_datapath/DUT/s_result
add wave -radix hex /tb2_second_datapath/DUT/s_rd_data
add wave /tb2_second_datapath/s_MemToReg
add wave -radix hex /tb2_second_datapath/DUT/s_rs1_out
add wave -radix hex /tb2_second_datapath/DUT/s_rs2_out
add wave -radix hex /tb2_second_datapath/DUT/s_B_SRC_Choice
add wave -radix hex /tb2_second_datapath/DUT/s_result
add wave -radix hex /tb2_second_datapath/DUT/s_rd_data
add wave -radix hex /tb2_second_datapath/DUT/RISC_V_REGISTERS/risc_registers(1)
add wave -radix hex /tb2_second_datapath/DUT/RISC_V_REGISTERS/risc_registers(2)

#run 5000

examine -radix hex /tb2_second_datapath/DUT/MEMORY_BLOCK/ram(0)
examine -radix hex /tb2_second_datapath/DUT/MEMORY_BLOCK/ram(1)
examine -radix hex /tb2_second_datapath/DUT/MEMORY_BLOCK/ram(256)
examine -radix hex /tb2_second_datapath/DUT/MEMORY_BLOCK/ram(500)

#instruction read out # 
echo "lab 2 -- how'd I do? :-)" 