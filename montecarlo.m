function [score, survival, score_samples, survival_samples] = ...
    montecarlo(ammo, ship_values, num_missiles, num_episodes)
% Monte Carlo Simulation of Computing Weighted Survival. 
%
% This function gives an monte carlo estimate given the current ammo and
% the number of incoming missiles, when you DO NOT know the missile type 
% nor their targets.
%
% INPUT
%   ammo :   amount of countermeasure ammo left [column vector]
%   ship_values[a] :   value of ship a
%   num_missiles :  number of incoming missiles
%   num_episodes :  montecarlo episodes
%
% OUTPUT
%   score :   mean score estimate over all MC samples
%   survival :   mean estimate of unweighted survival prob. of ships
%
% Written by Joseph Kim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global CM

score_samples = zeros(num_episodes,1);
survival_samples = zeros(num_episodes, numel(ship_values));

for z = 1 : num_episodes
    
    % Display
    fprintf('MC episode %d / %d\n',[z, num_episodes]);
    
    % Uniform sample targeting matrix
    num_ships = numel(ship_values);
    target_mat = zeros(num_ships,num_missiles);
    for j = 1 : num_missiles
        index = randi([1 num_ships]);
        target_mat(index,j) = 1;
    end

    % Uniform sample missile types
    mtypes = {'moth','hungry','green','eagle'};
    num_cm_types = numel(CM('moth'));
    mmat = zeros(num_cm_types,num_missiles);
    for j = 1 : num_missiles
        id = randi([1 numel(mtypes)]);
        mtype = mtypes{id};
        mmat(:,j) =  CM(mtype);
    end

    % Solve
    [~,fval, p_survivals] = solveAssignment(mmat, target_mat, ammo, ship_values);
    score_samples(z) = fval;
    survival_samples(z,:) = p_survivals;

end

% Obtain mean estimates
score = mean(score_samples);
survival = mean(survival_samples,1);





