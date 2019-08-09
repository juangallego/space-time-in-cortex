%
% Main file for space and time in cortex project
%


clear; close all


% set paths
cd('/home/juan/Documents/Code/space-time-in-cortex'); % go to root folder
matfigroot = '/home/juan/Documents/Results/Space_time_in_cortex';
dataroot = '/home/juan/Documents/Data/Mouse_Mesoscope_Data';


% datasets to use
db_use = [1:4 6:7]; % Datasets 9 to 11 are missing the cell coordinates, Dataset 8 is missing one of the two cameras 

% define which ones are the "good mice" among them (used for "good mice"
% only plots)
par.idx_good_mice = [1 2 4 6];


% grab info about datasets
compile_spontdbs; % Note that the GAD mouse and another one are commented out


% Get parameters
params_space_time;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Compute pairwise (neural) correlations vs. distance

pairwise_corr_dist;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1B. Shared neural variance fcn(number number latent signals)

shared_neural_variance_vs_n_cells;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Pairwise (neural) corr vs. dist after subtracting behavior subspace 

pairwise_corr_dist_after_subtract_behavior;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Neural variance reliably explained by the latent signals and behavior

relation_neural_PCs_behavior;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Shared neural variance explained by latent dynamics depends
% on the area of the cortical surface considered 

shared_variance_vs_surface;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5. Activity embedding

activity_embed;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHECKING STUFF
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% A. Examine behavioral data

check_behav_data;

