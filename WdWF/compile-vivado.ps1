#!/bin/bash
xvlog -nolog -sv --incr -L uvm -uvm_version 1.2 -i cpu-src/Projektowanie_Lab -i tb tb/tb_top.sv cpu-src/Projektowanie_Lab/ALU.v
xelab -nolog --incr --debug off -L uvm work.tb_top

rm xelab.pb
rm xvlog.pb
