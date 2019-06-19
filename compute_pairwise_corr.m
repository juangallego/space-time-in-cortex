%
% Compute pairwise neural correlations (vs distance)
%
% Inputs:
%    - X: data matrix (NN x NT)
%    - dist: distance between cells (NN x NN)
% Outputs:
%    - r: correlation matrix
%    - all_r: vector with all pairwise corrs
%    - all_dist: vector with the corresponding pairwise distances
%


function varargout = compute_pairwise_corr( X, varargin )


if nargin == 2
    dist = varargin{1};
end

r = corr(X','rows','pairwise');

% keep only the upper triangular part --and for the dist as well
pwr = triu(r,1);

% turn into a vector and get rid of lower diagonal elements
all_r = reshape(pwr,1,[]);


% compute associated distances, and 
if exist('dist','var')

    % keep only upper triangular distance matrix
    pwdist = triu(dist,1);
    
    all_dist = reshape(pwdist,1,[]);

    flag_zerodist = all_dist == 0;

    all_r(flag_zerodist) = [];

    all_dist(flag_zerodist) = [];
end


% return outputs
if nargout >= 1
    varargout{1} = r;
end
if nargout >= 2
    varargout{2} = all_r;
end
if nargout == 3
    varargout{3} = all_dist;
end

end
    