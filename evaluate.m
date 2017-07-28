function [total_score,p_survival_total] = evaluate(planfile, ship_values)
% Evaluates user plan for the missile defense scenario.
%
% Note that the user only sets a plan addressing the immediate threat.
% Value for the future threat is estimated given remaining ammunition.
%
% INPUT:
%   planfile   = comma-separated text file denoting user plan
%       Rows represented countermeasure types
%           (order = decoy, flare, chaff, laser)
%       Column represent missiles
%           (order = A.Moth, B.Hungry, C.Hungry, D.Green, E.Eagle)
%   
%       planfile[i,j] denotes how many of countermeasure type i is assigned
%                      to an incoming missile j
%
% OPTIONAL:
%   ship_values = importance of each ship [1-100] with 100 being highest
%       (order = Aircraft Carrier, Cruise Ship, Patrol Boat)
%       (Set to [100 80 60] by default)
%
% OUTPUT:
%   total_score = weighted survivability of all ships including immediate
%                   and future threat
%
%   p_survival_total = UNWEIGHTED survival of each ship
%
%
% Written by Joseph Kim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Default ship values
if nargin < 2
    ship_values = [100 80 60];
end

% Read plan
X = csvread(planfile);


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
ship_values = 100*ship_values / sum(ship_values);
 
% Starting countermeasure availability
ammo = [5, 3, 3, 6]';

% Current missile matrix
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
% Current threat
[~, p_survival_current] = objecfun(X, mmat, p_target, ship_values);

% Future threat
ammo_remaining = ammo - sum(X,2);

% % Approach 1:  Monte Carlo
% num_episodes = 200;
% [score_future1, p_survival_future1, score_history, p_survival_history] = ...
%     montecarlo(ammo_remaining,ship_values, num_future_missiles, num_episodes);

% % Approach 2:  Treat each missile as a weight average missile.  Targeting
% % is also assumed to be uniformly distributed
% mtypes = {'moth', 'hungry','green','eagle'};
% temp = values(CM, mtypes);
% avgs = mean(horzcat(temp{:}),2);
% avg_mmat = repmat(avgs,1,3);
% num_ships = numel(ship_values);
% avg_ptarget = repmat(ones(num_ships,1)/num_ships, 1, num_future_missiles);
% [~,score_future2, p_survival_future2] = solveAssignment(avg_mmat, avg_ptarget, ...
%     ammo_remaining, ship_values);

% Approach 3: Taking account the distribution of missile types
[~,~, p_survival_future] = solveAssignment2...
    (num_future_missiles, ammo_remaining, ship_values);


% Total score
p_survival_total = p_survival_current .* p_survival_future;
total_score = ship_values * p_survival_total;


end


