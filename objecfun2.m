function [f, p_survivals] = objecfun2(X, num_missiles, ship_values)
% Calculates objective metric (total weighted survival score) for the
% missile defense scenario GIVEN task assignment variable
%
% NOTES:
%   You DO NOT know the missile types and targets
%   -(so let's assume uniform distribution)
%
% INPUT:
%   X[d,m] = number of countermeasure d assigned to an incoming missile m
%   num_missiles
%   ship_values[a] = value of ship a
%
% OUTPUT:
%   f = total weighted survivability of all assets
%   p_survivals[a] = UNWEIGHTED prob. of survival of asset a
%
% Written by Joseph Kim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global CM
num_cm_types = numel(CM('moth'));

% If necessary, reshape the vectorized input to original X matrix format
if isrow(X)
    X = reshape(X,[num_missiles,num_cm_types])';
end

% Get cm effectiveness mat
num_missile_types = numel(keys(CM));
p_type = 1 / num_missile_types;
mmat = horzcat(CM('hungry'), CM('moth'), CM('green'), CM('eagle'));
p_target = 1 / numel(ship_values);


% Compute objective metric f
f = 0;
p_survivals = zeros(numel(ship_values), 1);
for a = 1: numel(ship_values)

    survival_a = 1;
    
    for m = 1 : num_missiles

        surv_a_t = 0;
        for t = 1 : num_missile_types
            
            pmiss = 1;
            for d = 1 : num_cm_types
                % Probability that missile m gets through
                pmiss = pmiss * (1-mmat(d,t))^X(d,m);
            end

            % Prob. that asset a survives missile m when type = t
            surv_a_t = surv_a_t + p_type * (1 - p_target * pmiss);
            
        end
                
        % Probability that asset a survives threats
        survival_a = survival_a * surv_a_t;

    end

    % Total weighted survability over all assets
    f = f + ship_values(a) * survival_a;
    p_survivals(a) = survival_a;
    
end

% Maximize by minimizing -f
f = f * -1;

end
