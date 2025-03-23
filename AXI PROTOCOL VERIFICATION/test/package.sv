


// package 

package pkg;

//import uvm_pkg.sv
	import uvm_pkg::*;
//include uvm_macros.sv
	`include "uvm_macros.svh"
	
	`include "destin_config.sv"
	`include "source_config.sv"
	`include "tb_env_config.sv"
	
	`include "destin_xtn.sv"
	`include "source_xtn.sv"
	
	`include "source_driver.sv"
	`include "source_seqr.sv"
	`include "source_monitor.sv"
	`include "source_seq.sv"
	`include "source_agent.sv"
	`include "source_agent_top.sv"
	
	
	`include "destin_driver.sv"
	`include "destin_seqr.sv"
	`include "destin_monitor.sv"
	`include "destin_seq.sv"
	`include "destin_agent.sv"
	`include "destin_agent_top.sv"
	`include "tb_scoreboard.sv"
	`include "tb_env.sv"
	`include "base_test.sv"	



/*
destin_agent.sv      destin_config.sv  destin_monitor.sv  destin_seq.sv
destin_agent_top.sv  destin_driver.sv  destin_seqr.sv     destin_xtn.sv

source_agent.sv      source_config.sv  source_monitor.sv  source_seq.sv
source_agent_top.sv  source_driver.sv  source_seqr.sv     source_xtn.sv

tb_env_config.sv  tb_env.sv  top.sv
base_test.sv  package.sv

tb_scoreboard.sv
*/


endpackage