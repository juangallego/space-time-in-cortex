%
% Does PCA of neural data. 
% input is 
%

function [PCs, scores, var_expl] = pca_neural(X,par)


if par.useGPU
    X = gpuArray(single(X));
end


% compute the eigenvectors
[u, s, ~] = svdecon(X); 


max_nPCs = max(par.nPC);
PCs = gather(u(:,1:max_nPCs));

% compute the "scores", i.e. the projection of the neural data onto the
% eigenvectors
scores = PCs' * gather(X);

% compute the amount of variance explained
s = gather(s);
var_expl = (s * s')/(size(X,2)-1);
var_expl = diag(var_expl);


end
