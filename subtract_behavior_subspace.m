%
% Subtracts the behavior subspace from the "total" neural data
%
% Inputs:
%   - X: neural data (NN x NT)
%   - M: behavioral data (NM x NT)
%
% Outputs
%   - U_xm
%   - X_noM: neural data without the projections onto behavior-related
%   dimensions


function [X_noM, U_xm] = subtract_behavior_subspace( X, M, par )

if par.useGPU
    X = gpuArray(X);
    M = gpuArray(M);
end


X = zscore(X,0,2);


% Covariance matrix (NN x NM)
Cxm = X * M';


% Decompose Cxm
[U_xm, ~, ~] = svdecon(Cxm);

% Uxm defines the subspace in X where the behavior-related information
% lives. We can compute the behavior-related neural activity as:
X_M = U_xm * ( U_xm' * X );


% Then the behavior-subtracted neural data becomes:
X_noM = X - X_M;


if par.useGPU
    X_noM = gather(X_noM);
    U_xm = gather(U_xm);
end

end