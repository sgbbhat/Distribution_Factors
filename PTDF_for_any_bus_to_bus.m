
Prepare_Data_for_any_bus_to_any_bus;

prompt = 'Enter the bus number where power is being injected:  ';
S_injection_bus = input(prompt);
Sbus=S_injection_bus;
prompt = 'Enter the bus number where power is being removed:  ';
 R_removal_bus = input(prompt);
Rbus = R_removal_bus;
 
%the bus_connections matrix is same as the B matrix
 bus_connections=B;

 
% this portion of the code from line 14 to 27 replaces the non-zero
% elements of the the bus_connections matrix with '1'

for i = 1:numbus
    for j = 1:numbus
        if bus_connections(i,j)~=0
            bus_connections(i,j)=1; 
        else
            bus_connections(i,j)=0;
            j=j+1;
        end
    end
        i=i+1;
end




            
%Create biograph object (biograph is a Data structure containing generic
%interconnected data to implement a graph

BGobj = biograph(bus_connections);

L = tril(bus_connections,-1);

BGobj2=biograph((L));
view(BGobj2)

% find the distance and shortest path from bus 'S' to bus 'R' (that is from
% S_injection_bus to R_removal_bus)

[dist, path] = shortestpath(BGobj,S_injection_bus,R_removal_bus );


fprintf(' \n Distance from bus %d to bus %d is: %d  \n ',S_injection_bus,R_removal_bus,dist);

fprintf(' \n Path from bus %d to bus %d is:  \n ',S_injection_bus,R_removal_bus);

for l = 1:dist
fprintf(' %d',path(l));
l=l+1;
end
fprintf(' %d',R_removal_bus);

count=0;
k=0;
i=0;
j=0;

%now suppose we are injecting power into bus 2 and removing it at bus 8. 
%Let's say, the shortest path is from 2->5->8. The 'PTDF_s_to_r' matrix stores the
%PTDF values of all lines corresponding to the transaction between 2->5 %and 5->8. 
%Since there is a line between 2->5 and 5->8, we can extract
%the PTDF coulumns (2->5 and 5->8) from the PTDF table and sum them up
%to give us the PTDF of all lines corresponding to a transaction between 2->8.
 
PTDF_s_to_r=[];

% This part of the code is difficult to understand as I have written it in a bad way.
% Basically we traverse the 'frombus' and 'tobus' arrays until we reach the
% desired line. In the first iteration for = 1: dist, we reach the line 2->5
%and in the next iteration we reach line 5->8.

for i = 1:dist
    
   S_injection_bus=path(i);
    R_removal_bus=path(i+1);
    
    for j=1:numline
             if frombus(j)==S_injection_bus
                         for k=1:j
                                  if tobus(k)==R_removal_bus
                                      if j==k
                                      count=1;   
                                      break;                                      
                                      end
                                 
                                  
                                  end
                         end
             
                
            end
        if count==1
        break;
        end
                  
    end
    count=0;  
   
% we append the PTDF columns into the PTDF_S_to_r matrix 
PTDF_s_to_r=[PTDF_s_to_r PTDF(:,j)];


   
end

% we perform column wise addition to the get the final PTDF values.

S = sum(PTDF_s_to_r,2);
  
fprintf('\n');
    fprintf('\n');
    fprintf('%s\n','POWER TRANSFER DISTRIBUTION FACTOR (PTDF) VECTOR');
    fprintf('%s\n','Monitored      Transaction');
    fprintf('%s\n','Line           From(Sell) - To(Buy)');
    fprintf('\n');
    fprintf('%s','              ');
    
        fprintf('%2d %s %2d %s',Sbus,'to',Rbus,'   ');
        fprintf('\n');
    fprintf('\n');


    for imon = 1 : numline 
        fprintf('%2d %s %2d %s',frombus(imon),'to', tobus(imon),'    ');
        fprintf('%8.4f %s',S(imon),'   ');
        fprintf('\n');
    end

    
    