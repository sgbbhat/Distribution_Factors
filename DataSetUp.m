% Set up data for calculations

% Determine the reference bus

for ibus = 1:numbus
  if Bustype(ibus) == 'S'
     refbus = ibus;
  end
end


% The model is made up of buss connected by transmission paths. Each transmission
% path is made up of one or more circuits in parallel.
% fbus is the FROM bus number for the path
% tobus is the TO bus number for the path
% xckt is the inductive reactance of the circuit making up the path
% flowmax is the max MW flow in each line

% if Line_flow_limits = 1 the limits will go in as entered on spreadsheet
% if Line_flow_limits = 0 line flow limits ignored

flowmax_multiplier = 1;
if Line_flow_limits == 0
    flowmax_multiplier = 100.; % set to 100 all limits will be so large that they will never be met
end

% if Contingency_Limits = 1 the limits will go in as entered on spreadsheet
%         times contingency limits adjustment variable climadj
% if Contingency_Limits = 0 line flow limits ignored

contingency_flowmax_multiplier = climadj;
if Contingency_Limits == 0
    contingency_flowmax_multiplier = 100.; % set to 100 all limits will be so large that they will never be met
end


for iline = 1:numline
   fbus(iline) = frombus(iline);
   tbus(iline) = tobus(iline);
   xline(iline) = X(iline);
end


for ibus = 1:numbus
   Pload_fix(ibus) = Pload(ibus) * baseMVA;
end

% BIDDING DATA
% Each function represents the cost of power at a generator


% Each bid must have a separate function associated with it. The functions, C(P) and
% W(P) are quadratic functions. GENERATION asking price function and LOAD worth of 
% power function.

% Both the asking price of power, C(P) and the worth of power, W(P) functions are 
% quadratic functions:

%  C(P) = A + B*P + C*P^2   and   W(P)= A + B*P + C*P^2
%
% where A = bidA
%       B = bidB
%       C = bidC

% in all the examples here the A coefficient is zero
% the coefficients for C(P) should all be positive or zero
% the coefficients for W(P) should all be negative or zero

% In addition, the bids have a min (bidmin) and a max (bidmax)
% for generators bidmin and bidmax are the min and max generation output respectively
% for loads midmin and bidmax are the min and max MW to be taken by the load.

% Finally, each bid is associated with one bus (here each bus has one bus so you can
% think of the bus number as being the same as the bus number in the bus



for igen = 1:numgen
   
   %Acoeff(igen) = gencost_inputdata(igen,7);
   %Bcoeff(igen) = gencost_inputdata(igen,6);
   %Ccoeff(igen) = gencost_inputdata(igen,5);
   ftnmin(igen) = Pmin(igen) * baseMVA;
   ftnmax(igen) = Pmax(igen) * baseMVA;
   ftnbus(igen) = genbus(igen);
   
end


