function [f, p_survivals] = objecfun(X, mmat, p_target, ship_values)
% Calculates objective metric (total weighted survival score) for the
% missile defense scenario GIVEN the task assignment
%
% ASSUMPTIONS:
%   -You know the type of each incoming missile
%   -You know where the missiles are headed (represented by p_target)
%
% INPUT:
%   X[d,m] = number of countermeasure d assigned to an incoming missile m
%   mmat[d,m] = Prob that cm d neutralizes missile m
%   p_target[a,m] = prob. that ship a is being targeted by missile m
%   ship_values[a] = value of ship a
%
% OUTPUT:
%   f = total weighted survivability of all assets
%   p_survivals[a] = UNWEIGHTED prob. of survival of asset a
%
% Written by Joseph Kim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_cm_types = size(mmat,1);
num_missiles = size(mmat,2);

% If necessary, reshape the vectorized input to original X matrix format
if isrow(X)
    X = reshape(X,[num_missiles,num_cm_types])';
end

% Compute objective metric f
f = 0;
p_survivals = zeros(numel(ship_values), 1);
for a = 1:numel(ship_values)

    survival_a = 1;
    for m = 1 : num_missiles

        pmiss = 1;
        for d = 1 : num_cm_types
            % Probability that missile t gets through
            pmiss = pmiss * (1-mmat(d,m))^X(d,m);
        end

        % Probability that asset a survives threats
        survival_a = survival_a * (1 - p_target(a,m) * pmiss);

    end

    % Total weighted survability over all assets
    f = f + ship_values(a) * survival_a;
    p_survivals(a) = survival_a;
    
end

% Maximize by minimizing -f
f = f * -1;

end
