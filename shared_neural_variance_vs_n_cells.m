%
% Compute percentage reliable shared neural variance as function of number
% of **randomly selected** cells
%


% Nbr of cells
nCells = 2.^[10:14];

% Nbr PCs in the latent space
nPCs_latent = 512;


% -------------------------------------------------------------------------
% Set nbr of repetitions when doing SVCA to 1
par.n_reps_reliable_var = 1;


% -------------------------------------------------------------------------
% preallocate variables
resVarvsCells.cov_neur = nan(length(db_use),length(nCells),nPCs_latent,par.n_reps_reliable_var);
resVarvsCells.var_neur = nan(length(db_use),length(nCells),nPCs_latent,par.n_reps_reliable_var);
resVarvsCells.reliable_neural_var = nan(length(db_use),length(nCells),nPCs_latent);



% -------------------------------------------------------------------------

ctr = 1;

% do
for d = db_use

    tic;
    
    disp(['Processing spont_' db(d).mouse_name '_' db(d).date]);
    
    data = load(fullfile(dataroot, ...
        ['spont_' db(d).mouse_name '_' db(d).date]));
    
   
    % ---------------------------------------------------------------------
    % Preprocess the data: compute distances, subsample and de-mean
    [X, xc, yc, nc, nt] = preprocess_neural_data_space_time( data, par );


    if par.useGPU, X = gpuArray( X ); end
 
    
    
    % ---------------------------------------------------------------------
    % Do
    
    % do for different manifold dimensionalities
    idx_max_nCells = find( nCells == max( nCells( nCells < nc ) ) );
    
    % shuffle cell idxs, for randomly selecting subsets
    rndCells = randperm(nc);
    
    
    for ic = 1:idx_max_nCells
        
        % what cells to consider
        idx_cells = rndCells(1:nCells(ic));

        
        % repeat 'par.n_reps_reliable_var' times
        for rep = 1:par.n_reps_reliable_var

       
            [cov_neur, var_neur] = rel_pred_neural_var( X(idx_cells,:), ...
                                    nPCs_latent, par );

            cov_neur = gather_try(cov_neur);
            var_neur = gather_try(var_neur);


            % store results
            resVarvsCells.cov_neur(ctr,ic,1:nPCs_latent,rep) = cov_neur;
            resVarvsCells.var_neur(ctr,ic,1:nPCs_latent,rep) = var_neur;
         
        end
        
        % compute reliable variance
        resVarvsCells.reliable_neural_var(ctr,ic,:) = ...
            nanmean( resVarvsCells.cov_neur(ctr,ic,:,:) ./ ...
            resVarvsCells.var_neur(ctr,ic,:,:), 4 );
    end
    
    resVarvsCells.max_nCells(ctr) = nCells(idx_max_nCells);

    
    % ---------------------------------------------------------------------
    % Plot for this dataset?

    if par.plot_interm

        cols = cool(idx_max_nCells);
        
        for ic = 1:idx_max_nCells, lgd{ic} = num2str(nCells(ic)); end
        
        fhi = figure; hold on
        for ic = 1:idx_max_nCells
            plot(squeeze(resVarvsCells.reliable_neural_var(ctr,ic,:)),...
                'color',cols(ic,:))
        end
        set(gca,'Xscale','log','TickDir','out')
        hlgi = legend(lgd,'Location','NorthEast'); legend boxoff
        title(hlgi,'# of cells')
        % hleg.Title.NodeChildren.Position
        xlim([0 nPCs_latent]),ylim([0 1])
        ylabel('Reliable neural variance explaiend (%)')
        xlabel('SVC dimension')
        title(['spont_' db(d).mouse_name '_' db(d).date],'Interpreter','none');
        
        clear lgd;
        
        if par.save_figs
            saveas(fhi,fullfile([matfigroot filesep ...
                'reliable_var_fcn_nbr_cells_' db(d).mouse_name ...
                '_' db(d).date '.png']));
        end
    end
    
    % ---------------------------------------------------------------------
    ctr = ctr + 1;

    toc;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Summary plots


% -------------------------------------------------------------------------
% ALL MICE


% Grand mean for the different numbers of cells
idx_max_nCells_all = find( nCells == max(resVarvsCells.max_nCells) );
mn_rel_var_vs_cells = zeros( nPCs_latent, idx_max_nCells_all );
sem_rel_var_vs_cells = zeros( nPCs_latent, idx_max_nCells_all );

for ic = 1:idx_max_nCells_all
    mn_rel_var_vs_cells(:,ic) = nanmean( resVarvsCells.reliable_neural_var(:,ic,:),1 );
    sem_rel_var_vs_cells(:,ic) = nanstd( resVarvsCells.reliable_neural_var(:,ic,:),1, 1 )/sqrt(length(db_use));
end


for ic = 1:idx_max_nCells_all, lgda{ic} = num2str(nCells(ic)); end

cols_all = cool(idx_max_nCells_all);

fha = figure; hold
for ic = 1:idx_max_nCells_all
    shadedErrorBar( 1:nPCs_latent, mn_rel_var_vs_cells(:,ic), ...
        sem_rel_var_vs_cells(:,ic), 'lineprops', {'color',cols_all(ic,:),...
        'markerfacecolor',cols_all(ic,:)})
end
set(gca,'XScale','log','TickDir','out')
xlabel('SVC Dimension'),ylabel('Neural variance explained (%)')
title('All mice')
xlim([0 nPCs_latent]),ylim([0 1])
lgah = legend(lgda,'Location','NorthEast'); legend boxoff
title(lgah,'# of cells')


% -------------------------------------------------------------------------
% GOOD MICE

idx_good_mice = [1 2 4 6];


% Grand mean, etc. Same as above
idx_max_nCells_good = find( nCells == max(resVarvsCells.max_nCells(idx_good_mice)) );
mn_rel_var_vs_cells_good = zeros( nPCs_latent, idx_max_nCells_all );
sem_rel_var_vs_cells_good = zeros( nPCs_latent, idx_max_nCells_all );

for ic = 1:idx_max_nCells_all
    mn_rel_var_vs_cells_good(:,ic) = nanmean( resVarvsCells.reliable_neural_var(idx_good_mice,ic,:),1 );
    sem_rel_var_vs_cells_good(:,ic) = nanstd( resVarvsCells.reliable_neural_var(idx_good_mice,ic,:),1, 1 )...
        /sqrt(length(db_use(idx_good_mice)));
end


fhag = figure; hold
for ic = 1:idx_max_nCells_all
    shadedErrorBar( 1:nPCs_latent, mn_rel_var_vs_cells_good(:,ic), ...
        sem_rel_var_vs_cells_good(:,ic), 'lineprops', {'color',cols_all(ic,:),...
        'markerfacecolor',cols_all(ic,:)})
end
set(gca,'XScale','log','TickDir','out')
xlabel('SVC Dimension'),ylabel('Neural variance explained (%)')
title('All "good" mice')
xlim([0 nPCs_latent]),ylim([0 1])
lgah = legend(lgda,'Location','NorthEast'); legend boxoff
title(lgah,'# of cells')


% -------------------------------------------------------------------------

if par.save_figs
    saveas(fha,fullfile([matfigroot filesep ...
                'reliable_var_fcn_nbr_cells_pooled_across_mice.png']));

    saveas(fhag,fullfile([matfigroot filesep ...
                'reliable_var_fcn_nbr_cells_pooled_across_good_mice.png']));
end


% -------------------------------------------------------------------------

clearvars -except par res* db* dataroot matfig*
clear res_pred_neural_beh
