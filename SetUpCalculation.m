% function [OPFoutputs] = OPFcalc_QP(OPFdata);
function SetUpCalculation(OPFdata)


% file OPFcalc.m
% This is file OPFcalc it is called by routine OPF, it calls dfactcalc
% Given the segA, segB, , segmin, segmax and segBus vectors it
% calculates the flow limited optimal allocation of load and generation
% and returns the bus prices, the bus generations and bus loads.

% Each bus may have fixed load (baseload) and fixed generation (basegen) due to 
% bilateral transactions that are outside the bidding process but must be accounted in 
% the transmission loading.

%build OPFdata tables
%print_flag = OPFdata.print_flag;
numgen = OPFdata.numgen;
%Acoeff = OPFdata.Acoeff;
%Bcoeff = OPFdata.Bcoeff;
%Ccoeff = OPFdata.Ccoeff;
ftnmin = OPFdata.ftnmin;
ftnmax = OPFdata.ftnmax;
ftnbus = OPFdata.ftnbus;
Pload_fix = OPFdata.Pload_fix;
numbus = OPFdata.numbus;
numline = OPFdata.numline;
refbus = OPFdata.refbus;
Contingency_Limits = OPFdata.Contingency_Limits;
climadj = OPFdata.climadj;
Line_flow_limits = OPFdata.Line_flow_limits;
printfactorsflag=OPFdata.printfactorsflag;
flowmax_multiplier = OPFdata.flowmax_multiplier;
contingency_flowmax_multiplier = OPFdata.contingency_flowmax_multiplier;
frombus = OPFdata.frombus;
tobus = OPFdata.tobus;
xline = OPFdata.xline;
flowmax = OPFdata.flowmax;
BranchStatus = OPFdata.BranchStatus;

flow = zeros(numline,numbus);
B = zeros(numbus,numbus);
Bx = zeros(numbus,numbus);
X = zeros(numbus,numbus);
Pload_var = zeros(1,numbus);
Pnetbase = zeros(numbus,1);
gencost = zeros(numgen,1);
lambda_gen = zeros(numgen,1);
lambda_contingency = zeros(numline,1);
contsave = zeros(numline,4);
contdetected = zeros(numline,numline);



% Calculate LODF factors
%dfactcalc;
calc_FACTORS
% flow
% Bx
% B



