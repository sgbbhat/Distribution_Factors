%pfdatainput
% Power flow data input, build Y matrix


% Input Data File 
[file,pathname] = uigetfile('*networkdata.xls*','Select Network Data Spreadsheet File');
if (pathname == 0),
    error('You Must Select A Valid Data File')
end
S=file;          % Name of the File that we need to read

fprintf(' Case ID: %s \n',file);


[Parameter_data, Parameter_Character_Data] = xlsread(S, 'Parameters');
[bus, Character_Data] = xlsread(S, 'BusData');
[gen, Character_Data] = xlsread(S, 'GenData');
[branch, Character_Data] = xlsread(S, 'BranchData');
[area, Character_Data] = xlsread(S, 'AreaData');
[areanamedata, areaname] = xlsread(S, 'AreaName');
%[gencost_inputdata, Character_Data] = xlsread(S, 'GenCostData');

baseMVA                    = Parameter_data(1);
baseKV                     = Parameter_data(2);
casemult                   = Parameter_data(3);
Rmult                      = Parameter_data(4);
varlimit                   = cell2mat(Parameter_Character_Data(5,2));
powerflow_tolerance        = Parameter_data(6);
Maxiter                    = Parameter_data(7);
LPOPF_convergence          = Parameter_data(8);
delta_upper                = Parameter_data(9);
delta                      = Parameter_data(10);
tau                        = Parameter_data(11);
gamma                      = Parameter_data(12);
nu                         = Parameter_data(13);
printpowerflow_convergence = Parameter_data(14);
printpowerflow_bussummary  = Parameter_data(15);
printLPmove_summary        = Parameter_data(16);
print_summary_graphs       = Parameter_data(17);
Contingency_Limits         = Parameter_data(18); 
climadj                    = Parameter_data(19);
Line_flow_limits           = Parameter_data(20);
printfactorsflag           = Parameter_data(21);


[numbus,N] = size(bus);
[numline,N] = size(branch);
[numgen,N] = size(gen);
[numarea,N] = size(area);

% numbus
% numline
% numgen
% numarea

Bustype = zeros(1,numbus);
Bustype_start = zeros(1,numbus);

for ibus = 1:numbus
   Bustype(ibus)= ' ';
end

Pload = zeros(1,numbus);
Qload = zeros(1,numbus);
Vmax = zeros(1,numbus);
Vmin = zeros(1,numbus);

frombus = zeros(1,numline);
tobus = zeros(1,numline);
R = zeros(1,numline);
X = zeros(1,numline);
Bcap = zeros(1,numline);
flowmax = zeros(1,numline);
BranchStatus = zeros(1,numline);
Vsched = zeros(1,numgen);
Pgen = zeros(1,numgen);
Qgen = zeros(1,numgen);
Pmax = zeros(1,numgen);
Pmin = zeros(1,numgen);
Qmax = zeros(1,numgen);
Qmin = zeros(1,numgen);
genbus = zeros(1,numgen);
busgen = zeros(1,numbus);
original_genbus = zeros(1,numgen);

for ibus = 1:numbus
      bustype_number = bus(ibus,2);
   if bustype_number == 1 
     Bustype(ibus) = 'L';
  end  
  if bustype_number == 2 
     Bustype(ibus) = 'G';
  end  
  if bustype_number == 3 
     Bustype(ibus) = 'S';
     refbus = ibus;
  end  
   Bustype_start(ibus) = Bustype(ibus);
   Pload(ibus) = bus(ibus,3)* casemult/baseMVA;
   Qload(ibus) = bus(ibus,4)* casemult/baseMVA;
   Vmax(ibus) = bus(ibus,12);
   Vmin(ibus) = bus(ibus,13);
end
% Pload
% Qload
% Vmax
% Vmin
for igen = 1:numgen
   ibus = gen(igen,1);
   genbus(igen) = ibus;
   busgen(ibus) = igen;
   original_genbus(igen) = ibus;
   Pgen(igen) = gen(igen,2)* casemult/baseMVA;
   Qgen(igen) = gen(igen,3)* casemult/baseMVA;
   Pmax(igen) = gen(igen,9)/baseMVA;
   Pmin(igen) = gen(igen,10)/baseMVA;
   Qmax(igen) = gen(igen,4)/baseMVA;
   Qmin(igen) = gen(igen,5)/baseMVA;
   if varlimit == 'N'
      Qmax(igen) = 99.;
      Qmin(igen) = -99.;
   end
   Vsched(igen) = gen(igen,6);
end
for iline = 1:numline
   frombus(iline) = branch(iline,1);
   tobus(iline)   = branch(iline,2);
   %R(iline)       = branch(iline,3);
   X(iline)       = branch(iline,4);
   %Bcap(iline)    = branch(iline,5);
   flowmax(iline) = branch(iline,6);
   BranchStatus(iline) = branch(iline,11);
end
Y = zeros(numbus,numbus);
for iline = 1:numline
    if BranchStatus(iline) == 1
        Y(frombus(iline),tobus(iline)) = Y(frombus(iline),tobus(iline))-1/(sqrt(-1)*X(iline));
        Y(tobus(iline),frombus(iline)) = Y(tobus(iline),frombus(iline))-1/(sqrt(-1)*X(iline));
    end
end
for ibus = 1:numbus
    Y(ibus,ibus) = -sum(Y(ibus,:));
end
for iline = 1:numline
    if BranchStatus(iline) == 1
        Y(frombus(iline),frombus(iline)) = Y(frombus(iline),frombus(iline))+sqrt(-1)*Bcap(iline)/2;
        Y(tobus(iline),tobus(iline)) = Y(tobus(iline),tobus(iline))+sqrt(-1)*Bcap(iline)/2;
    end
end

%G=real(Y);
B=sparse(imag(Y));

%rline = R;
xline = X;
Slack = refbus;

%Init voltage and angle Variables
v = ones(1,numbus);
angle = zeros(1,numbus);
v = bus(:,8);
angle = bus(:,9)*(pi/180);
for igen = 1:numgen
    ibus = genbus(igen);
    v(ibus) = Vsched(igen);
end

nbus = numbus;                % Number of buses
ncircuits = numline;               % Number of Interfaces between buss


for iline = 1:numline
   fbus(iline) = frombus(iline);
   tbus(iline) = tobus(iline);
   xckt(iline) = X(iline);
   flowmax_perckt(iline) = flowmax(iline);
   monitor_circuit(iline) = BranchStatus(iline);
end
