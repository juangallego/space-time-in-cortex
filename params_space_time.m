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
% Relationship neural PCs and behavior

% repetitions to estimate "reliable variance"
par.n_reps_reliable_var = 10;