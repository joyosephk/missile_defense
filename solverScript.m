% Solves for a plan in the missile defense problem
% Uses genetic algorithm solver (REQUIRES Global Optimization Toolbox)
%   -Stochastic
%   -Suboptimal solver (may have to run repeatedly to get better solutions)
%
% Written by Joseph Kim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; close all; clear;

%% SCENARIO PARAMETERS

% Countermeasure effective table
% -CM order: [decoy, flare, chaff, laser]
global CM
CM = containers.Map;
CM('hungry') = [60 70 60 70]'/100;
CM('moth') = [40 80 0 70]'/100;
CM('green') = [30 0 80 70]'/100;
CM('eagle') = [0 0 0 30]'/100;

% Asset ship_values [1-100] with 100 representing highest value
ship_values = [100 80 60];
ship_values = 100*ship_values / sum(ship_values);
num_ships = numel(ship_values);
 
% SET: Starting countermeasure availability (ammo count)
ammo = [5, 3, 3, 6]';

% Current missile matrix
%   mmat[i,j] = prob. that cm i neutralizes missile j
current_missiles = {'moth', 'hungry','hungry','green','eagle'};
temp = values(CM, current_missiles);
mmat = horzcat(temp{:});

% Missile targeting probabilities
%   p[i,j] = prob that asset i is being targeted by incoming missile j
%       Columns must sum to one
p_target = [1, 1, 0, 0, 1/3;
           0, 0, 0, 1, 1/3;
           0, 0, 1, 0, 1/3];    
       
% Future missile threat
num_future_missiles = 3;


%% Threat Calculation

% Combine current and future missile threat
mtypes = {'moth', 'hungry','green','eagle'};
temp = values(CM, mtypes);
avgs = mean(horzcat(temp{:}),2);
avg_mat = repmat(avgs,1,num_future_missiles);

% Modify missile matrix
mat_overall = horzcat(mmat, avg_mat);

% Modify targeting matrix
avg_ptarget = repmat(ones(num_ships,1)/num_ships, 1, num_future_missiles);
p_target_overall = horzcat(p_target, avg_ptarget);

%% Solve section
% Construct optimization variables
n = size(mat_overall,1);       % num of countermeasure types
m = size(mat_overall,2);       % num of missiles
nVar = m*n;

% Inequality constraint matrix
% -This enforces ammo constraint
orow = ones(1,m);
A = zeros(n, nVar);
for i = 1:n
    % Fill in diagonals
    id_start = (i-1)*m +1;
    id_end = i*m;
    A(i,id_start:id_end) = orow;
end

% Upper and lower bounds
IntCon = 1:nVar;
lb = zeros(nVar,1);
ub = reshape(repmat(ammo,1,m)', [nVar, 1]);

% GA solver
opts = optimoptions('ga','PopulationSize',300,'MaxStallGenerations',60,...
    'FunctionTolerance',1e-12,'MaxGenerations',500,'PlotFcn',@gaplotbestf,'Display','off');
xbest = ga(@(X)objecfun(X, mat_overall, p_target_overall, ship_values),...
    nVar,A,ammo,[],[], lb,ub,[],IntCon,opts);
[f, p_survivals] = objecfun(xbest, mat_overall, p_target_overall, ship_values);
xbest = reshape(xbest,[m,n])';
score = abs(f);


%% Solution output
% Immediate threat assignment matrix
disp('Immediate Threat Assignment matrix')
nNames = {'1.Decoy'; '2.Flare'; '3.chaff'; '4.Laser'};
A_Moth = xbest(:,1);
B_Hungry = xbest(:,2);
C_Hungry = xbest(:,3);
D_Green = xbest(:,4);
E_Eagle = xbest(:,5);

t = table(A_Moth, B_Hungry, C_Hungry, D_Green, E_Eagle,'RowNames',nNames)
score
p_survivals


