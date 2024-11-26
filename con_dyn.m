function  [sys,x0,str,ts] = con_dyn(t,x,u,flag,qk0)

% knee model (Riener,Fuhr)
% 
%
% new implemented by Thomas Schauer 16/10/98


switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0     
    [sys,x0,str,ts] = mdlInitializeSizes(qk0);                                

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1,
    sys = mdlDerivatives(t,x,u);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys = mdlOutputs(t,x,u);
 
  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9                                                
    sys = []; % do nothing

end

%end simom

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes(qk0)

sizes = simsizes;

sizes.NumContStates  = 6;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 1;
sizes.NumInputs      = 9;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;


sys = simsizes(sizes);
x0  = [0.16*pi,0,qk0,0,0.45*pi,0]; 
str = [];
ts  = [0 0];


% end mdlInitializeSizes
%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys = mdlDerivatives(t,x,u)

m=4.3;
J=0.05;
l_cog=0.28;
lx=0;
ly=0;
ml=0;
g=9.81;

q=x(1:2:5);
dq=x(2:2:6);

act=u;
J_all=J+l_cog^2*m+(lx^2+ly^2)*ml;
M_K_g=g*cos(q(2))*l_cog*m+g*(sin(q(2))*lx+cos(q(2))*ly)*ml;
M_K_ela=-3.1*exp(-5.9*(1.92-q(2)))+10.5*exp(-17*(q(2)-0.05));
M_K_vis=-0.6*dq(2);  %this is false, but the same as by riener
Fmax=[1850 2370 2190 400 1000 5200 1600 3600 1100]';
F=Fmax.*act.*ffv(q,dq).*ffl(q);
M_act=ma(q)'*F;
M_K=M_act(2)+M_K_ela+M_K_vis+M_K_g;



sys=[0
     0
     x(4);
     M_K/J_all;
     0
     0];	

% end mdlDerivatives
%
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%
function sys = mdlOutputs(t,x,u)
sys = x(3);


% end mdlOutputs


function out=ffl(q)
epsi=[0.4 0.5 0.4 0.2 0.4 0.45 0.3 0.5 0.4]';
c=[0.165 	
   0.05
   0.09
   0.18
   0.11
   0.04
   0.06
   0.028
   0.09];
	intma=zeros(9,3);
   intma(5,3)=-0.045*q(3);
   intma(5,2)=+0.036*q(2);
	intma(6,2)=0.034*q(2);

   %intma(5,3)=-(1/120*q(3)^3+41/200*q(3)^2-1/25*q(3));
   %intma(5,2)=-(29/2000*exp(-2*q(2)^2)-71/2500*q(2));
   %intma(6,2)=-(-7/400*exp(-2*q(2)^2)-1/40*q(2));
   
   l=c+intma*ones(3,1);
   lopt=[0.146
	      0.11
   	   0.121
      	0.173
	      0.086
	      0.086
	      0.054
	      0.033
         0.099];
  out=exp(-((l./lopt-1)./epsi).^2);	

function out=ffv(q,dq)
   v=-ma(q)*dq;
	vm=[0.73 0.54 0.48 0.69 0.51 0.48 0.32 0.1 0.36]';
	out=0.54*atan(5.69*(v./vm)+0.51)+0.745;   

function out=ma(q)
	out(7,1) = 0.053;
	out(8,1) = 0.035;
    out(9,1) = 0.013*q(1)-0.035;
   
	out(3,2)=-0.0098*q(2)^2 + 0.021 + 0.0277;
	out(4,2)=-0.008*q(2)^2  + 0.027*q(2) + 0.014;
	out(5,2)=-0.058*exp(-2*q(2)^2)*q(2) - 0.0284;
	out(6,2)=-0.07*exp(-2*q(2)^2)*q(2)  - 0.025;
    out(7,2)=0.018;	
   
    out(1,3) = 0.00233*q(3)^2-0.00223*q(3)-0.0275;
	out(2,3) =-0.0098*q(3)^2-0.0054*q(3)+0.0413;
	out(3,3) =-0.02*q(3)^2-0.024*q(3)+0.055;
    out(5,3) = 0.025*q(3)^2+0.41*q(3)-0.040;
	%	coloumn joint  1=A,2=K,3=H
   %	row muscle
   
function m=mdiag(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)

