function  [A,B]=creAB

Tca=[0.04 0.04 0.05 0.05 0.03 0.04 0.05 0.07 0.06]'; 
a2=-2./Tca;
a1=-1./Tca.^2;
b1=1./Tca.^2;
clear A;
i=1
A=[0 1; a1(i) a2(i)];
B=[0
   b1(i)];
for i=2:9,
   A=mdiagonal(A,[0 1;a1(i) a2(i)]);
   B=mdiagonal(B,[0;b1(i)]);
end;


function m=mdiagonal(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)

if nargin > 10, error('The number of input arguments is limited to 10'); end

m=a1;
for k=2:nargin
   [rm,cm]=size(m);
   eval(['[ra,ca]=size(a' int2str(k) ');']);
   eval(['m=[m zeros(rm,ca);zeros(ra,cm) a' int2str(k) '];']);
end

% dx1=x2
% dx2=a1*x1+a2*x2+b1*u
