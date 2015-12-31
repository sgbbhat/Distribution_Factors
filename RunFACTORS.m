
% Run PTDF and LODF factors
clear;
close all
clc
%********************************************************
print_flag = 1;


network_datainput_Excel

DataSetUp
tic
% **********************************************************************
%set up OPF data structure
OPFdata.print_flag = print_flag;
OPFdata.numgen = numgen;
%OPFdata.Acoeff = Acoeff;
%OPFdata.Bcoeff = Bcoeff;
%OPFdata.Ccoeff = Ccoeff;
OPFdata.ftnmin = ftnmin;
OPFdata.ftnmax = ftnmax;
OPFdata.ftnbus = ftnbus;
OPFdata.Pload_fix = Pload_fix;
OPFdata.numbus = numbus;
OPFdata.numline = numline;
OPFdata.refbus = refbus;
OPFdata.Contingency_Limits = Contingency_Limits; % 18
OPFdata.climadj = climadj; % 19
OPFdata.Line_flow_limits = Line_flow_limits; % 20
OPFdata.printfactorsflag = printfactorsflag; % 21
OPFdata.flowmax_multiplier = flowmax_multiplier;
OPFdata.contingency_flowmax_multiplier = contingency_flowmax_multiplier;
OPFdata.frombus = frombus;
OPFdata.tobus = tobus;
OPFdata.xline  = xline;
OPFdata.flowmax = flowmax;
OPFdata.BranchStatus = BranchStatus;
% *******************************************************************
%-------------------------------------------------------------------------------------------

SetUpCalculation(OPFdata);

toc
%-------------------------------------------------------------------------------------------

% Print Results
%print_results_QP(OPFdata, OPFoutputs)
