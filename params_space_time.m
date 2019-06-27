%
% Parameters for space time project
%


% -------------------------------------------------------------------------
% Common to all the scripts

par.useGPU = 1; % setting this to zero may break things

% how many bins to combine (downsampling)
par.tbin = 1; 

% "block" size take random blocks of data, not random samples
par.Lblock = round(60/.8); 

% Number of PCs for the different analyses
par.nPC = 2.^(0:11);


% plot intermediary figures?
par.plot_interm = true;
par.save_figs = true;

% -------------------------------------------------------------------------
% Pairwise correlation analysis

% how to set a boundary to define what's a strong peer: a) 'pctile'
% threshold based on the corr distribtion; b) 'threshold' based on some
% threshold value

par.strong_corr_criterion = 'pctile';
par.pctile_strong_corr = 99.9;
par.thres_strong_corr = 0.5;


% to compute distributions
par.x_hist_dist_step = 100; % step fr distance histogram (um)
par.x_hist_dist_max = 6600; % close to the max I think

par.x_hist_corr_step = 0.025; % step fr distance histogram (um)
par.x_hist_corr_max = 1.025; % close to the max I think


% -------------------------------------------------------------------------
% Subspace subtraction

% what cameras to use?
par.cam_behavior = 'cam1'; % 'cam1' (face camera) or 'all' (all cams)

% how to normalize the data: by divided by the SD of PC1 ('sd_pc1') or the
% difference between the 95th and 5th percentile ('95th_minus_5th')
par.norm_cams = 'sd_pc1'; % 'sd_pc1'; '95th_minus_5th'
    

% -------------------------------------------------------------------------
% Reliably estimate percentage of neural variance explianed by X latent
% signals

% repetitions to estimate "reliable variance"
par.n_reps_reliable_var = 10;

% block size (for splitting into training and testin sets)
par.Lblock_reliable_var = round(60/.8);

% Percentage of blocks that will be used for model training (PCA)
par.fractrain_reliable_var = 0.5;


% -------------------------------------------------------------------------
% Relationship neural PCs and behavior

% Movie PCs used to predict neural activity
par.n_behavPC = 2.^[0:7];

% Number of neural PCs for the RRR-like analysis (CanonCor2) where we
% predict neural activity from an increasing number of behavior PCs
par.n_neuralPCs_from_behav = 1024;


% delay between movie data and neural data (Applied on the neural data).
% Can be a scalar or a vector to loop through. In number of bins
par.delay_behav_neural = [0 1];

% Percentage of blocks using for training SVCA models, and models that
% predict neural activity from behavior
par.fractrain_behav_neural = 0.5;

% Lambda to regularize the models that predict neural activity from
% behavior
par.lambda_neural_behav = .15; 