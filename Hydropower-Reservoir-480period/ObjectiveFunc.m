function [x,Penalized_fit,fit]=ObjectiveFunc(x,Inflow,Loss)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Charged System Search (CSS) Optimization Algorithm          %%%
%%%  Objective Function code - Hydropower Reservoir Operation    %%%
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

TWL=172; % TailWater elevation (per m)
power=650; % Total capacity of hydroelectric plant (per MW)

C_min=100;

Storage=zeros(NT,1); % Storage of reservoir in the end of periods
Head=zeros(NT,1); % Water Elevation of reservoir in the end of periods
P_t=zeros(NT,1); % Power genearated in the periods (per MW)
h_t=zeros(NT,1); % Mean water elevation in the end of periods
MUL=0.3858; % A coefficient for converting Release(i,1) from MCM to M3/s ( 1e6 / 30*24*3600 )

Storage(1,1)=S_initial+Inflow(1,1)-Release(1,1)-(Loss(1,1)/1000)*(11.291+0.0157*S_initial);

Pen_min=zeros(NT,1);

if Storage(1,1)<S_min

    Pen_min(1,1)=C_min*(1-(Storage(1,1)/S_min));
end
if Storage(1,1)>S_max

    Storage(1,1)=S_max;
end

Head_initial=249.83364+0.0587205*S_initial-(1.37e-5)*(S_initial^2)+(1.562e-9)*(S_initial^3);
Head(1,1)=249.83364+0.0587205*Storage(1,1)-(1.37e-5)*(Storage(1,1)^2)+(1.562e-9)*(Storage(1,1)^3);
h_t(1,1)=((Head_initial+Head(1,1))/2)-TWL;
P_t(1,1)=min(((9.81*0.9*Release(1,1))/0.417)*(h_t(1,1)/1000)*MUL,power);


for i=2:NT

    Storage(i,1)=Storage(i-1,1)+Inflow(i,1)-Release(i,1)-(Loss(i,1)/1000)*(11.291+0.0157*Storage(i-1,1));
    if Storage(i,1)<S_min

        Pen_min(i,1)=C_min*(1-(Storage(i,1)/S_min));
    end

    if Storage(i,1)>S_max

        Storage(i,1)=S_max;
    end

    Head(i,1)=249.83364+0.0587205*Storage(i,1)-(1.37e-5)*(Storage(i,1)^2)+(1.562e-9)*(Storage(i,1)^3);
    h_t(i,1)=((Head(i-1,1)+Head(i,1))/2)-TWL;
    P_t(i,1)=min(((9.81*0.9*Release(i,1))/0.417)*(h_t(i,1)/1000)*MUL,power);

end


% Objective Function Calculation
fit=0;

for i=1:NT

    fit=fit+(1-(P_t(i,1)/power));

end

% Penalty Calculation
penalti=0;

for i=1:NT

    penalti=penalti+Pen_min(i,1);

end

Penalized_fit=fit+penalti;

end
