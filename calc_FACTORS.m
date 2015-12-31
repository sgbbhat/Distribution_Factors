% this code builds the LODF and PTDF matrices
% PTDF - POWER TRANSFER DISTRIBUTION FACTORS
% LODF - LINE OTAGE DISTRIBUTION FACTORS




PTDF = zeros(numline,numline);    % PTDF matrix
LODF = zeros(numline,numline);    % LODF matrix 
RadialLines = zeros(1,numline);   % table of lines shows radials
Bx = zeros(numbus,numbus);        % Bx matrix
Bd = zeros(numline,numline);      % diagonal matrix only
A = zeros(numline,numbus);        % line incidence matrix
flow = zeros(numline,numbus);     % line flow matrix


for iline = 1 : numline
 if BranchStatus(iline) == 1
      i = frombus(iline);
      j = tobus(iline);
      flow( iline, i ) =  1.0/xline(iline);
      flow( iline, j ) = -1.0/xline(iline);
 end
end

% build Bx matrix
for iline = 1 : numline
 if BranchStatus(iline) == 1
  Bx( frombus(iline), tobus(iline) )   =  Bx( frombus(iline), tobus(iline) )   - 1/xline(iline);
  Bx( tobus(iline),   frombus(iline) ) =  Bx( tobus(iline),   frombus(iline) ) - 1/xline(iline);
  Bx( frombus(iline), frombus(iline) ) =  Bx( frombus(iline), frombus(iline) ) + 1/xline(iline);
  Bx( tobus(iline),   tobus(iline) )   =  Bx( tobus(iline),   tobus(iline) )   + 1/xline(iline);
 end
end

B = Bx;

%Bx(refbus,refbus) = Bx(refbus,refbus) + 10000000. ; % old 1
%Bx(refbus,refbus) = Bx(refbus,refbus) + 0.0000001;  % old 2

% zero row and col for refbus, then put 1 in diag so we can invert it
Bx(:,refbus) = zeros(numbus,1);
Bx(refbus,:) = zeros(1,numbus);
Bx(refbus,refbus) = 1.0;

% get X matrix for use in DC Power Flows
Xmatrix = MatrixInverse(Bx);
Xmatrix(refbus,refbus)=0; % set the diagonal at the ref bus to zero for a short to ground
Xmatrix;

for iline = 1 : numline
    if BranchStatus(iline) == 1
      i = frombus(iline);
      j = tobus(iline);
      Bd(iline,iline) = 1.0/xline(iline);
      A(iline,i) =  1.0;
      A(iline,j) = -1.0;
    end
end

B_diag = sparse(Bd);

%Determine Radial Lines
NumberOfLines_matrix = A'*A;
NumberOfLines = diag(NumberOfLines_matrix);
radial_bus_location = [];
radial_bus_location = find(NumberOfLines==1);
radial_bus_location

num_radialline = 0;
for n=1:length(radial_bus_location)
radial_bus = radial_bus_location(n);
        for iline = 1:numline
            if BranchStatus(iline) == 1
                if radial_bus == frombus(iline)
                    num_radialline = num_radialline + 1;
                    %RadialLines(num_radialline) = iline;
                    RadialLines(iline) = 1;
                end
            end
        end
end

for n=1:length(radial_bus_location)
radial_bus = radial_bus_location(n);
        for iline = 1:numline
            if BranchStatus(iline) == 1
                if radial_bus == tobus(iline)
                    num_radialline = num_radialline + 1;
                    %RadialLines(num_radialline) = iline;
                    RadialLines(iline) = 1;
                end
            end
        end
end
%RadialLines
%RadialLines
line_location_connecting_radial_bus = [];
line_location_connecting_radial_bus  = find(RadialLines==1);

% alter A and Bx to reflect radial lines, used only in LODF calculations
A_alt = sparse(A);
Bx_alt = sparse(Bx);

%Create A_alt matrix to account for radial lines
for iline = 1:numline
    if BranchStatus(iline) == 1
        if RadialLines(iline) == 1
            radial_bus = radial_bus_location(find(iline == line_location_connecting_radial_bus));
            A_alt(iline,radial_bus) = 0;
        end
    end
end

%Create Bx_alt matrix to account for radial lines
for ibus = 1:numbus
    if NumberOfLines(ibus) == 0 | ibus == refbus
        for jbus = 1:numbus
            Bx_alt(ibus,jbus) = 0;
        end
        Bx_alt(ibus,ibus) = 1;
    end
end

X_alt = MatrixInverse(Bx_alt);
X_alt(refbus,refbus)=0; % set the diagonal at the ref bus to zero for a short to ground


% basic expression for PTDF matrix which includes the PTDF(K,K) on
% diagonals and is compensated for radial lines.

PTDF = B_diag*A_alt*X_alt*A_alt';
B_diag
A_alt


% set PTDF diagonal to zero for radial lines
for iline = 1:numline
    if RadialLines(iline) == 1
        PTDF(iline,iline) = 0;
    end
end
PTDF;

% LODF(L,K) (or dfactor) = PTDF(L,K) / (1 - PTDF(K,K) ) 

% First we need to check to see that a line outage will not cause islanding
% this is detected when the diagonal of any line in PTDF is very close to
% 1.0. In this case if such a line is detected, we force the PTDF(K,K) to
% zero so that we do not get a divide by zero and issue an error warning of
% islanding.

PTFD_denominator = PTDF;
%diag(PTFD_denominator)

for iline = 1:numline
        if (1.0 - PTFD_denominator(iline,iline) ) < 1.0E-06
            PTFD_denominator(iline,iline) = 0.0;
            fprintf(' Loss of line from %3d to %3d will cause islanding \n',frombus(iline), tobus(iline));
        end
end

% diag(PTDF) extracts the diagonals of PTDF matrix into a vector
% diag(diag(PTDF)) extracts diags of PTDF matrix and put them into a matrix
% of the same size with all zeros in off diagonals.
% expression below multiplies the PTDF matrix by a matrix with diagonals
% equal to 1/(1 - PTDF(K,K))

LODF = PTDF*MatrixInverse( speye(numline)-diag(diag(PTFD_denominator)) );

for iline = 1:numline
      LODF(iline,iline) = 0;
end
   
LODF;

if printfactorsflag == 1
    
    %--------------------------------------------------------------------
    %--------------------------------------------------------------------

    % Calculate the single injection to line flow factor matrix
    % call this the afact matrix. Assumes injections are positive and
    % compensated by an equal negative drop on the reference bus

    Bx2 = B;
    Bx2(refbus,refbus) = Bx2(refbus,refbus) + 10000000. ; % makes matrix non singular

    Xmatrix = MatrixInverse(Bx2);

    % loop on the monitored line imon from i to j
    for imon = 1 : numline

         i = frombus(imon);
         j = tobus(imon);

        % loop on injection bus s
        for s = 1 : numbus
         if s ~= refbus
            afact(imon,s) = (1/xline(imon))*(Xmatrix(i,s) - Xmatrix(j,s));
         else
            afact(imon,s) = 0.0;
         end
        end
    end
    
    fprintf('%s\n','AFACT MATRIX');
    fprintf('%s\n','Monitored      GENERATOR');
    fprintf('%s\n','Line           ');
    fprintf('\n');
    fprintf('%s','              ');
      for s = 1 : numbus
          fprintf('%s %2d %s','  ',s,'      ');
      end
    fprintf('\n');
    fprintf('\n');


    for imon = 1 : numline 
        fprintf('%2d %s %2d %s',frombus(imon),'to', tobus(imon),'    ');
        for s = 1 : numbus
            fprintf('%8.4f %s',afact(imon,s),'   ');
        end
        fprintf('\n');
    end
   
    %--------------------------------------------------------------------
    fprintf('\n');
    fprintf('\n');
    fprintf('%s\n','POWER TRANSFER DISTRIBUTION FACTOR (PTDF) MATRIX');
    fprintf('%s\n','Monitored      Transaction');
    fprintf('%s\n','Line           From(Sell) - To(Buy)');
    fprintf('\n');
    fprintf('%s','              ');
    for t = 1 : numline
        fprintf('%2d %s %2d %s',frombus(t),'to',tobus(t),'   ');
    end
    fprintf('\n');
    fprintf('\n');


    for imon = 1 : numline 
        fprintf('%2d %s %2d %s',frombus(imon),'to', tobus(imon),'    ');
        for t = 1 : numline
           fprintf('%8.4f %s',PTDF(imon,t),'   ');
        end
        fprintf('\n');
    end
    
    %--------------------------------------------------------------------
    fprintf('\n');
    fprintf('\n');
    fprintf('%s\n','LINE OUTAGE DISTRIBUTION FACTOR (LODF) MATRIX');
    fprintf('%s\n','Monitored      Outage of one circuit');
    fprintf('%s\n','Line           From - To');
    fprintf('\n');
    fprintf('%s','              ');
    for idrop = 1 : numline
        fprintf('%2d %s %2d %s',frombus(idrop),'to',tobus(idrop),'   ');
    end
    fprintf('\n');
    fprintf('\n');


    for imon = 1 : numline 
       fprintf('%2d %s %2d %s',frombus(imon),'to', tobus(imon),'    ');
           for idrop = 1 : numline
                fprintf('%8.4f %s',LODF(imon, idrop),'   ');
           end
           fprintf('\n');
    end
    fprintf('\n');
    fprintf('\n');
    
    
end

