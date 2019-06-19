%
% Main file for space and time in cortex project
%


clear; close all


% set paths
matfigroot = '/home/juan/Documents/Results/Space_time_in_cortex';
dataroot = '/home/juan/Documents/Data/Mouse_Mesoscope_Data';


% datasets to use
db_use = [1:4 6:7]; % Datasets 9 to 11 are missing the cell coordinates, Dataset 8 is missing one of the two cameras 

% grab info about datasets
compile_spontdbs; % Note that the GAD mouse and another one are commented out


% Get parameters
params_space_time;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Compute pairwise (neural) correlations vs. distance

pairwise_corr_dist;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Re-Compute pairwise (neural) correlations vs. distance after 
% removing behavior subspace 

pairwise_corr_dist_after_subtract_behavior;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Stability latent dynamics

relation_neural_PCs_behavior;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Spatial organization of behavioral subspaces

spatial_org_behavior_subspace;



