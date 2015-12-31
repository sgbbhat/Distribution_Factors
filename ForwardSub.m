function C=ForwardSub(L,b)
% Triangle Matrix Forward Substitution

s=length(b);
C=zeros(s,1);
C(1)=b(1)/L(1,1);
for j=2:s
    C(j)=(b(j) -sum(L(j,1:j-1)'.*C(1:j-1)))/L(j,j);
end
