function  [sys,x0,str,ts] = act_dyn(t,x,u,flag,X0,freq,A,B)

% knee model (Riener,Fuhr)
% 
%
% new implemented by Thomas Schauer 16/10/98


switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0     
    [sys,x0,str,ts] = mdlInitializeSizes(X0);                                

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1,
    sys = mdlDerivatives(t,x,u,freq,A,B);

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
function [sys,x0,str,ts] = mdlInitializeSizes(X0)

sizes = simsizes;

sizes.NumContStates  = 18;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 9;
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;


sys = simsizes(sizes);
x0  = [X0]; 
str = [];
ts  = [0 0];


% end mdlInitializeSizes
%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys = mdlDerivatives(t,x,u,freq,A,B)

K_thr=1;
K_sat=1;
d_sat=500;
d_thr=100;
c_1=1/2*2/pi*1/(d_sat-d_thr);
c_2=0.5;
alpha=0.1;

d=zeros(9,1);
f=zeros(9,1);
f(5:6)=freq;
d(5:6)=u;
act=x(1:2:17);


ar=c_1*((d-d_thr).*atan(K_thr*(d-d_thr))-(d-d_sat).*atan(K_sat*(d-d_sat)))+c_2;
af=((alpha*f).^2)./(1+(alpha*f).^2);

sys=[A*x(1:18)+B*(ar.*af)];	

% end mdlDerivatives
%
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%
function sys = mdlOutputs(t,x,u)
sys = x(1:2:17);


% end mdlOutputs




