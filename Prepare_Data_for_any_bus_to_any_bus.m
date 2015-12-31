% This code prpares the data required for PTDF calculation of any bus to any bus 
% by constructing PTDF matrices

PTDF = zeros(numline,numline);    % PTDF matrix
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
