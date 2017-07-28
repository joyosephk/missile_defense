function [ X, score, p_survivals ] = solveAssignment2( num_missiles, ammo, ship_values )
% Solves missile defense task allocation problem
%   -CASE WHEN YOU DON'T KNOW MISSILE TYPES and TARGETS
%   -Analytical version for the Monte Carlo approach
%
% INPUT:
%   num_missiles
%   ammo = available cm ammo
%   ship_values[a] = value of ship a
%
% OUTPUT:
%   X = task allocation
%   score = total weighted survivability score of all assets
%   p_survivals[a] = UNWEIGHTED prob. of survival of asset a
%
% Written by Joseph Kim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Construct optimization variables
global CM
n = numel(CM('moth'));  % num of countermeasure types
m = num_missiles;       % num of incoming missiles
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


%% GA solver
opts = optimoptions('ga','PopulationSize',50,'MaxStallGenerations',60,...
    'FunctionTolerance',1e-10,'MaxGenerations',150,'Display','off');
xbest = ga(@(X)objecfun2(X, num_missiles, ship_values),...
    nVar,A,ammo,[],[], lb,ub,[],IntCon,opts);
[f, p_survivals] = objecfun2(xbest, num_missiles, ship_values);
X = reshape(xbest,[m,n])';
score = abs(f);


end

