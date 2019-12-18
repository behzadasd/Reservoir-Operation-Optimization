function [x,Penalized_fit,fit]=ObjectiveFunc(x,Inflow,Demand,Loss)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Charged System Search (CSS) Optimization Algorithm          %%%
%%%  Objective Function code - Water-Supply Reservoir Operation  %%%
%%%        https://www.mdpi.com/2306-5338/6/1/5                  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Behzad Asadieh, Ph.D.           %%%
%%% University of Pennsylvania      %%%
%%% basadieh@sas.upenn.edu          %%%
%%% github.com/behzadasd            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Lower bounds
x_min=0;
% Upper bounds
x_max=1000;

for i=1:size(x,2) % checking the solutions [x(i)] to make sure there are inside the boundries
    if x(i)<x_min
        x(i)=x_min;
    end
    if x(i)>x_max
        x(i)=x_max;
    end
end

%%%%%%%%% Definition of Objective Function %%%%%%%%%

NT=480;

Release=x';
S_initial=1430;
S_min=830;
S_max=3340;
D_max=831.1;

C_min=100;

Storage=zeros(NT,1);
Storage(1,1)=S_initial+Inflow(1,1)-Release(1,1)-((Loss(1,1)/1000)*(11.291+0.0157*S_initial));

Pen_min=zeros(NT,1);

if Storage(1,1)<S_min
    
    Pen_min(1,1)=C_min*(1-(Storage(1,1)/S_min));
end
if Storage(1,1)>S_max
    
    Storage(1,1)=S_max;
end


for i=2:NT
    
    Storage(i,1)=Storage(i-1,1)+Inflow(i,1)-Release(i,1)-(Loss(i,1)/1000)*(11.291+0.0157*Storage(i-1,1));
    if Storage(i,1)<S_min
        
        Pen_min(i,1)=C_min*(1-(Storage(i,1)/S_min));
    end
    
    if Storage(i,1)>S_max
        
        Storage(i,1)=S_max;
    end
    
end

fit=0;

for i=1:NT
    
    fit=fit+(((Release(i,1)-Demand(i,1))/D_max)^2);
    
end

penalti=0;

for i=1:NT
    
    penalti=penalti+Pen_min(i,1);
    
end

Penalized_fit=fit+penalti;

end
