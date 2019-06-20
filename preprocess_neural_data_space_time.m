%
% Preprocess data (downsamples and de-means) and computes distances
%

function [X, xc, yc, nc, nt] = preprocess_neural_data_space_time( data, par )


% ---------------------------------------------------------------------
% Retrieve and compute basic stuff

% Cells' coordinates
xc = [data.stat.xglobal];
yc = [data.stat.xglobal];

% get number of neurons
nc = numel(xc);

% distance between somata
dist = sqrt( (repmat(xc,nc,1) - repmat(xc',1,nc)).^2 + ...
    (repmat(yc,nc,1) - repmat(yc',1,nc)).^2 );


% ---------------------------------------------------------------------
% Pre-processing

% downsample
X = bin2d( data.S(:,1:end), par.tbin, 2 );

% de-mean
X = X - mean(X,2);

% get number of bins
nt = size(X,2);
