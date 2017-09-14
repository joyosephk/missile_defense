% Some testing script
%
% -Currently designed to empirically assess what future threat calculation 
% procedure to use
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
% Example X
X = [0 1 2 2 0;
    2 1 0 0 0;
    0 0 1 2 0;
    0 0 0 3 3];

% Current threat
[f, p_survival_current] = objecfun(X, mmat, p_target, ship_values);

% Future threat
ammo_remaining = ammo - sum(X,2);

% % Approach 1:  Monte Carlo
% num_episodes = 10;
% [score_future1, p_survival_future1, score_history, p_survival_history] = ...
%     montecarlo(ammo_remaining,ship_values, num_future_missiles, num_episodes);
% % save('test.mat');

% Approach 2:  Treat each missile as a weight average missile.  Targeting
% is also assumed to be uniformly distributed
mtypes = {'moth', 'hungry','green','eagle'};
temp = values(CM, mtypes);
avgs = mean(horzcat(temp{:}),2);
avg_mmat = repmat(avgs,1,3);
num_ships = numel(ship_values);
avg_ptarget = repmat(ones(num_ships,1)/num_ships, 1, num_future_missiles);
[~,score_future2, p_survival_future2] = solveAssignment(avg_mmat, avg_ptarget, ...
    ammo_remaining, ship_values);

% Approach 3: Taking account the distribution of missile types
[~,score_future3, p_survival_future3] = solveAssignment2...
    (num_future_missiles, ammo_remaining, ship_values);


% Total survival
p_survival_total = p_survival_current .* p_survival_future2;
total_score = ship_values * p_survival_total;


