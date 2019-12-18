clc;
clear;
tic;

load Dez_data;
Inflow=Inflow480;
Loss=Loss480;

n=100;    % Number of CPs
n_dv=480;  % Number of Decision Variables
nt=4000;  %Number of  iterations
CM_cap=5; % Capacity of Charged Memory (CM)

a=0.000000001; % radious of charged sphares
K_a=0.5; % Acceleration Coefficient
K_v=0.5; % Velocity Coefficient

% CSS Hrmony-Search parameters
CMCR=0.95;PAR=0.1;bw=0.1;


% Lower boundary
x_min=0;
% Upper boundary
x_max=1000;


%Producing random initial solutions
X=x_min+(x_max-x_min).*rand(n,n_dv);


% Variable Preallocations
V_old=zeros(n,n_dv);  % Initial Velocities of CPs
X_cm=zeros(CM_cap,n_dv);
Penalized_FIT_cm=zeros(CM_cap,1);
FIT_cm=zeros(CM_cap,1);
f=zeros(n,n_dv);
All_FIT=zeros(nt,3);
ALL_Xcm=zeros(nt,n_dv);
Optimum=zeros(4+n_dv,1);

Optimum(4,1)=1e12;


%%% Initializing Matrices %%%%%%%%%
% First Step - Initializing FIT and Penalized_FIT matrices and CM
Penalized_FIT=zeros(n,1);
FIT=zeros(n,1);
for i=1:n
    x=X(i,:); % isolating every CP from main CP matrix and calculating its fitness
    [x_help,Penalized_fit,fit]=ObjectiveFunc(x,Inflow,Loss);
    X(i,:)=x_help; % x_help is an auxiliary variable for x - This part amends the probable violations from boundries in variables
    Penalized_FIT(i)=Penalized_fit;
    FIT(i)=fit;
end

[value,index]=sort(Penalized_FIT);
for i=1:CM_cap
    X_cm(i,:)=X(index(i,1),:);
    Penalized_FIT_cm(i,:)=Penalized_FIT(index(i,1),:);
    FIT_cm(i,:)=FIT(index(i,1),:);
end
fitbest=Penalized_FIT(index(1,1),1);
fitworst=Penalized_FIT(index(n,1),1);

X_best=X(index(1,1),1);
FIT_best=Penalized_FIT(index(1,1),1);

% Magnitude of initial charges matrix for CPs
q=zeros(n,1);
for i=1:n
    q(i,1)=(Penalized_FIT(i)-fitworst)/(fitbest - fitworst);
end

r=zeros(n,n);
for i=1:n
    for j=1:n
        if norm(((X(i,:)+X(j,:))/2)-X_best)~=0
            r(i,j)=(norm(X(i,:)-X(j,:)))/(norm(((X(i,:)+X(j,:))/2)-X_best));
        else
            r(i,j)=(norm(X(i,:)-X(j,:)))/(.00000001);
        end

    end
end



for t=1:nt

    for i=1:n
               
        p=zeros(n,n); % Producing probability function of attraction forces between CPs
        for k=1:n % k is as same as i - this change in name of variable is just because i is already being used in the procedure of the code
            for j=1:n
                if (((Penalized_FIT(k,1)-fitbest)/(Penalized_FIT(j,1)-Penalized_FIT(k,1)))>rand) || (Penalized_FIT(j,1)>Penalized_FIT(k,1))
                    p(k,j)=1; % p(k,j)=1 means that particle k can affect particle j and attract it toward itself (because k is better than j)
                else
                    p(k,j)=0;
                end
            end
        end

        % Electrical forces matrix - electric force of each CP in each direction
        fhelp=zeros(1,n_dv); % n_dv is equall to the number of Decision Variables
        for k=1:n
            if k~=i
                if r(k,i)<a
                    fhelp=fhelp+((q(k,1)/(a^3))*r(k,i))*p(k,i)*(X(k,:)-X(i,:));
                else
                    fhelp=fhelp+(q(k,1)/((r(k,i))^2))*p(k,i)*(X(k,:)-X(i,:));
                end
            end

        end
        f(i,:)=fhelp';


        V_new=zeros(1,n_dv); % new velocities of CPs
        X_new=zeros(1,n_dv);
        % Calculating new X and V for CPs
        X_new(1,:)=K_a*(1+t/nt)*rand * f(i,:)+K_v*(1-t/nt)*rand * V_old(i,:) + X(i,:);
        V_new(1,:)=X_new(1,:)-X(i,:);

        % in case of if an agent violates the boundries - amending the violation using Harmony Search rules
        for j=1:n_dv
            if (X_new(1,j)<x_min) || (X_new(1,j)>x_max)
                if rand < CMCR
                    X_new(1,j)=X_cm(ceil(rand*(CM_cap)),j);
                    if rand < PAR
                        if rand < 0.5
                            X_new(1,j)=X_new(1,j)+bw*rand;
                        else
                            X_new(1,j)=X_new(1,j)-bw*rand;
                        end
                    end
                else
                    X_new(1,j)=x_min+(x_max-x_min)*rand;
                end
            end
        end

        X(i,:)=X_new(1,:);
        V_old(i,:)=V_new(1,:);
        
        
        %%% Objective Function evaluation for new position of particle i -
        %%% to be used in the next step by other particles
        x=X(i,:); % isolating every CP from main CP matrix and calculating its fitness
        [x_help,Penalized_fit,fit]=ObjectiveFunc(x,Inflow,Loss);
        X(i,:)=x_help; % x_help is an auxiliary variable for x - This part amends the probable violations from boundries in variables
        Penalized_FIT(i)=Penalized_fit;
        FIT(i)=fit;

        % Updating X_best for current iteration
        if Penalized_FIT(i)<FIT_best
            FIT_best=Penalized_FIT(i);
            X_best=X(i,:);
        end

        help_X=zeros(1+CM_cap,n_dv);
        help_Penalized_FIT=zeros(1+CM_cap,1);
        help_FIT=zeros(1+CM_cap,1);

        % Updating X_CM matrix after evaluation of each CP in each iteration
        for k=1:(1+CM_cap)
            if k==1
                help_X(1,:)=X(i,:);
                help_Penalized_FIT(1,:)=Penalized_FIT(i,:);
                help_FIT(1,:)=FIT(i,:);
            else
                help_X(k,:)=X_cm((k-1),:);
                help_Penalized_FIT(k,:)=Penalized_FIT_cm((k-1),:);
                help_FIT(k,:)=FIT_cm((k-1),:);
            end
        end
        [value,index]=sort(help_Penalized_FIT);
        for k=1:CM_cap
            X_cm(k,:)=help_X(index(k,1),:);
            Penalized_FIT_cm(k,:)=help_Penalized_FIT(index(k,1),:);
            FIT_cm(k,:)=help_FIT(index(k,1),:);
        end

        % because [fitbest and fitworst are the SO FAR best and the worst fitness of all particles !]
        if Penalized_FIT(i)<fitbest
            fitbest=Penalized_FIT(i);
        end
        if Penalized_FIT(i)>fitworst
            fitworst=Penalized_FIT(i);
        end


        % Magnitude of charge for current CP
        q(i,1)=(Penalized_FIT(i)-fitworst)/(fitbest - fitworst);
        
        % Updating r for particle i
        for j=1:n
            if norm(((X(i,:)+X(j,:))/2)-X_best)~=0
                r(i,j)=(norm(X(i,:)-X(j,:)))/(norm(((X(i,:)+X(j,:))/2)-X_best));
            else
                r(i,j)=(norm(X(i,:)-X(j,:)))/(.00000001);
            end

        end
        help_r=r(i,:);
        r(:,i)=help_r';

    end
    [c1,c2]=min(Penalized_FIT);  % because [xbest is the position of the best CURRENT cp ] [ c1=Value of min Fit , c2=Index of min Fit ]
    X_best=X(c2,:);
    FIT_best=Penalized_FIT(c2,1);



    disp('Penalized_FIT_cm = ');
    disp('                 ');
    disp(Penalized_FIT_cm);               % this part prints the Matrix of Penalized fitness for Charged Memory at each iteration
    [t,FIT_cm(1,1),Penalized_FIT_cm(1,1)] % this part prints the number of itteraion and its best fitness at each iteration
    All_FIT(t,:)=[t,FIT_cm(1,1),Penalized_FIT_cm(1,1)];
    ALL_Xcm(t,:)=X_cm(1,:);

    if  Optimum(4,1)-Penalized_FIT_cm(1,1)>0.000002
        Optimum(1,1)=t;
        Optimum(2,1)=t*n;
        Optimum(3,1)=FIT_cm(1,1);
        Optimum(4,1)=Penalized_FIT_cm(1,1);
        for i=5:4+n_dv
            Optimum(i,1)=X_cm(1,i-4);
        end
    end
end

disp('                                                                                            ');
disp('********************************************************************************************');
disp('*      Charged System Search (CSS) Optimizer         -        Final Results                *');
disp('********************************************************************************************');
disp('                                                                                            ');
disp('FIT_cm : Charged Memory Solutions Fitnesses        ');
disp('                                                   ');
disp(FIT_cm);
disp('Penalized_FIT_cm : Charged Memory Solutions Fitnesses Considering Penalti        ');
disp('                                                                               ');
disp(Penalized_FIT_cm);
disp('********************************************************************************************');


%Final_Release=X_cm(1,:)';

%figure;
%for i=1:n_dv
%    subplot(1,1,i);
%    plot(Final_Release(i,:),'b');
%    hold on;
%    plot(Demand(i,:),'r:');
%    legend('Release','Demands');
%    title('Dez Reservior Data');
%end

toc;






