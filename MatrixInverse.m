function Ainv=MatrixInverse(A)

% Do Lu decompositon to obtain triangle matrices 
S= sparse(A);
[L,U,P] = lu(S);

% Solve linear system for Identity matrix
I=eye(size(A));
s=size(A,1);
Ainv=zeros(size(A));
for i=1:s
    b=I(:,i);
    Ainv(:,i)=BackwardSub(U,ForwardSub(L,P*b));
end
