function [ X, score, p_survivals ] = solveAssignment( mmat, p_target, ...
    ammo, ship_values )
% Solves missile defense task allocation problem
%
% INPUT:
%   mmat[d,m] = Prob that cm d neutralizes missile m
%   p_target[a,m] = prob. that ship a is being targeted by missile m
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
n = size(mmat,1);       % num of countermeasure types
m = size(mmat,2);       % num of missiles
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
opts = optimoptions('ga','PopulationSize',100,'MaxStallGenerations',60,...
    'FunctionTolerance',1e-11,'MaxGenerations',200,'Display','off');
xbest = ga(@(X)objecfun(X, mmat, p_target, ship_values),...
    nVar,A,ammo,[],[], lb,ub,[],IntCon,opts);
[f, p_survivals] = objecfun(xbest, mmat, p_target, ship_values);
X = reshape(xbest,[m,n])';
score = abs(f);


end

