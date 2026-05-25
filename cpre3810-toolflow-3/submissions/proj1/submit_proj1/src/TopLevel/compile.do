#quit -sim 

if {[file exists work]} {
   #vdel -all --> has a chance to fail if the directory is corrupted 
   file delete -force work 
}
vlib work 

#vcom -2008 ./TPUFiles/*.vhd

#compiling the package 
vcom -2008 tRISCV_types.vhd 



vcom -2008 ./components/*.vhd

vcom -2008 ./TopLevel/*.vhd


echo "hardware ready for testing!" 