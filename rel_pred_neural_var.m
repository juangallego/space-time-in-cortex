%
% Estimate the fraction of reliably predictable neural variance
%
% Inputs:
%   - X: neural data (cells x time)
%   - nPCs: number of PCs of the neural manifold/latent space
%   - par: struct with cross-validation paramaters
% Outputs:
%   - cov_neur: cross-validated covariance across subpopulations of cells
%   - var_neur: arithmetic mean variances of test data for each
%   subpopulation of cells (% Reliable var = cov_neur./var_neur)
%   - U: left eigenvectors of covariance matrix btw ntrain and ntest on
%        itrain timepts
%   - V: right eigenvectors of covariance matrix btw ntrain and ntest on
%        itrain timepts
%
%

function [cov_neur, var_neur, U, V] = rel_pred_neural_var( X, nPCs, par )


% Split neurons into training and testing sets (half and half)
[nc, nt] = size(X);

nrand = randperm(nc);

cells_train = nrand(1:ceil(nc/2));
cells_test = nrand(ceil(nc/2)+1:end);

% Split time bins into training and testing sets
%    hardcoded to use 50 % of bins for training and 50 % for testing
[idx_train, idx_test] = splitInterleaved( nt, par.Lblock_reliable_var, par.fractrain_reliable_var, 1);


% Reliably estimate the shared variance
[cov_neur, var_neur, U, V] = SVCA( X, nPCs, cells_train, cells_test, ...
                                idx_train, idx_test );
