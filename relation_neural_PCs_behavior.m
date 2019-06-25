%
% 
%



% redefine some global params
nPCs = par.nPC; % Vector with the number of PCs that will be looped through for the different analysis


% preallocate some matrices
resPCsBehav.cov_neur = nan(length(db_use),length(par.nPC),max(par.nPC),par.n_reps_reliable_var);
resPCsBehav.var_neur = nan(length(db_use),length(par.nPC),max(par.nPC),par.n_reps_reliable_var);


ctr = 1;

disp(' '); disp('Studying relationship neural PCs and behavior'); disp(' ');


% do
for d = db_use

    tic;
    
    disp(['Processing spont_' db(d).mouse_name '_' db(d).date]);
    
    data = load(fullfile(dataroot, ...
        ['spont_' db(d).mouse_name '_' db(d).date]));
    
   
    % ---------------------------------------------------------------------
    % Preprocess the data: compute distances, subsample and de-mean
    [X, xc, yc, nc, nt] = preprocess_neural_data_space_time( data, par );


    
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % Shared variance: Reliably estimate variance in the manifold with SVCA
    
    
    if par.useGPU, X = gpuArray( X ); end
     
    
    % do for different manifold dimensionalities
    for dim = 1 : length( nPCs( nPCs < (nc/2) ) )
    
        % how many PCs (manifold dimensions) to consider
        n_dims = nPCs(dim);
        
        % repeat 'par.n_reps_reliable_var' times
        for rep = 1:par.n_reps_reliable_var


            % Compute reliable shared neural variance
            [cov_neur, var_neur] = rel_pred_neural_var(X, n_dims, par);

            
            cov_neur = gather_try( cov_neur ); 
            var_neur = gather_try( var_neur ); 

            % save results
            resPCsBehav.cov_neur(ctr,dim,1:n_dims,rep) = cov_neur;
            resPCsBehav.var_neur(ctr,dim,1:n_dims,rep) = var_neur;
            resPCsBehav.max_nPCs_reliable_var(ctr) = n_dims;
        end
    end
         
  

    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % How much neural variance can be reliably explained by behavior?
    
    
    % preprocess movie data
    M = preprocess_movie_data_space_time( data, par );
    

    if par.useGPU, M = gpuArray(M); end

    
    % ----------------------
    % Do
    res_pred_neural_beh = pred_neural_from_behav( X, M, par );
    

     % save results
    resPCsBehav.cov_res_behav(ctr,:,:) = res_pred_neural_beh.cov_res_beh';
    resPCsBehav.var_beh(ctr,:,:) = res_pred_neural_beh.var_beh';
    resPCsBehav.max_nPCs_beh(ctr) = min(size(M,1),max(par.n_behavPC));



    % ---------------------------------------------------------------------
    % Final calculations

    % max number of PCs shared across analyses
    nSharedPCs = min( max(nPCs( nPCs < (nc/2) )), ...
                        size(resPCsBehav.cov_res_behav,3) );

    % Reliable variance estimated from neural activity
    rel_var_neur = zeros( par.n_reps_reliable_var, nSharedPCs );
    idx_PCs = find( nPCs==nSharedPCs );
    for rep = 1:par.n_reps_reliable_var
        rel_var_neur(rep,:) = squeeze( resPCsBehav.cov_neur( ctr, idx_PCs, 1:nSharedPCs, rep ) ./ ...
            resPCsBehav.var_neur( ctr, idx_PCs, 1:nSharedPCs, rep ) );
    end

    % Variance *not* explained by the behavior
    [~, idx_max_nBehavPC] = max(par.n_behavPC);
    rel_var_unexpl_beh = squeeze( resPCsBehav.cov_res_behav( ctr, idx_max_nBehavPC, 1:nSharedPCs ) ./ ...
            resPCsBehav.var_neur( ctr, idx_PCs, 1:nSharedPCs, rep ) );



    % ---------------------------------------------------------------------
    % Save these results

    resPCsBehav.reliable_neural_var(ctr,:,:) = rel_var_neur';
    resPCsBehav.reliable_unexpl_beh(ctr,:) = rel_var_unexpl_beh;


    
    % ---------------------------------------------------------------------
    % Plot for this dataset?
    if par.plot_interm
        
        
        fhi = figure; 
        hold on
        plot( 1:nSharedPCs, mean( rel_var_neur, 1 )' - rel_var_unexpl_beh, ...
                'color', [.6 .6 .6], 'linewidth', 2 )
        plot( 1:nSharedPCs, mean(rel_var_neur,1), 'k', 'linewidth', 2 )
        set(gca,'XScale','log'), xlim([0 par.n_behavPC(end)])
        legend('behavior','max explainable'),legend boxoff
        xlabel('SVC dimension'), ylabel('Neural variance explained (%)')
        title(['spont_' db(d).mouse_name '_' db(d).date],'Interpreter','none')
        set(gca,'TickDir','out')
        ylim([0 1])


        if par.save_figs
            saveas(fhi,fullfile([matfigroot filesep ...
                'reliable_variance_expl_behav_spont_' db(d).mouse_name ...
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


% mice-specific colors
cols_mouse = parula(length(db_use)+2);

% make legend
lc = 1;
for d = db_use
    lgnd{lc} = [db(d).mouse_name '_' db(d).date];
    lc = lc + 1;
end


% -------------------------------------------------------------------------
% Reliable neural variance for all mice
reliable_var_all = nan(length(db_use),size(resPCsBehav.cov_neur,3));

fh = figure; hold on
for d = 1:length(db_use)

    % how many PCs to plot?
    idx_maxPCs = find(nPCs == resPCsBehav.max_nPCs_reliable_var(d));

    % compute reliable neural variance
    all_reps = resPCsBehav.cov_neur(d,idx_maxPCs,:,:) ./ ...
            resPCsBehav.var_neur(d,idx_maxPCs,:,:) ;
        
    reliable_var_all(d,:) = nanmean( squeeze(all_reps), 2)';

    plot( 1:nPCs(idx_maxPCs), reliable_var_all(d,1:nPCs(idx_maxPCs)), 'color',cols_mouse(d,:))
end
plot(nanmean(reliable_var_all,1),'k','linewidth',2)
set(gca,'XScale','log','TickDir','out')
xlabel('SVC Dimension'),ylabel('Neural variance explained (%)')
title('Reliable variance individual mice')
legend(lgnd,'Location','NorthEast','Interpreter','none'), legend boxoff
xlim([0 nPCs(end)]); ylim([0 1])



% -------------------------------------------------------------------------
% Reliable neural variance and how much is explained by behavior -- pooled
% across all mice

mn_rel_neural_var = mean( mean( resPCsBehav.reliable_neural_var, 3 ), 1);
sem_rel_neural_var = std( mean( resPCsBehav.reliable_neural_var, 3 ), 0, 1)/sqrt(length(db_use)-1);
mn_rel_var_expl_beh = mean( mean( resPCsBehav.reliable_neural_var, 3 ) - resPCsBehav.reliable_unexpl_beh, 1);
sem_rel_var_expl_beh = std( mean( resPCsBehav.reliable_neural_var, 3 ) - resPCsBehav.reliable_unexpl_beh, 1, 1)...
    /sqrt(length(db_use)-1);


fpa = figure; hold on
shadedErrorBar( 1:nSharedPCs, mn_rel_neural_var, sem_rel_neural_var, ...
 'lineprops',{'-k','markerfacecolor',[.5,.5,.5]})
shadedErrorBar( 1:nSharedPCs, mn_rel_var_expl_beh, sem_rel_var_expl_beh, ...
 'lineprops',{'-b','markerfacecolor',[0,0,.5]})
set(gca,'XScale','log','TickDir','out')
xlabel('SVC Dimension'),ylabel('Neural variance explained (%)')
title('All mice')
legend('Max. explainable','Behavior','Location','NorthEast','Interpreter','none'), legend boxoff
xlim([0 max(par.n_behavPC)]); ylim([0 1])



% -------------------------------------------------------------------------
% Reliable neural variance and how much is explained by behavior -- pooled
% across all "good mice"

idx_good_mice = [1 2 4 6];

mn_rel_neural_var_good = mean( mean( resPCsBehav.reliable_neural_var(idx_good_mice,:,:), 3 ), 1);
sem_rel_neural_var_good = std( mean( resPCsBehav.reliable_neural_var(idx_good_mice,:,:), 3 ), 0, 1)/sqrt(length(db_use)-1);
mn_rel_var_expl_beh_good = mean( mean( resPCsBehav.reliable_neural_var(idx_good_mice,:,:), 3 ) ...
                            - resPCsBehav.reliable_unexpl_beh(idx_good_mice,:), 1);
sem_rel_var_expl_beh_good = std( mean( resPCsBehav.reliable_neural_var(idx_good_mice,:,:), 3 ) ...
                            - resPCsBehav.reliable_unexpl_beh(idx_good_mice,:), 1, 1)...
                            /sqrt(length(db_use)-1);


fpag = figure; hold on
shadedErrorBar( 1:nSharedPCs, mn_rel_neural_var_good, sem_rel_neural_var_good, ...
 'lineprops',{'-k','markerfacecolor',[.5,.5,.5]})
shadedErrorBar( 1:nSharedPCs, mn_rel_var_expl_beh_good, sem_rel_var_expl_beh_good, ...
 'lineprops',{'-b','markerfacecolor',[0,0,.5]})
set(gca,'XScale','log','TickDir','out')
xlabel('SVC Dimension'),ylabel('Neural variance explained (%)')
title('All "good" mice')
legend('Max. explainable','Behavior','Location','NorthEast','Interpreter','none'), legend boxoff
xlim([0 max(par.n_behavPC)]); ylim([0 1])




% -------------------------------------------------------------------------

if par.save_figs
    saveas(fh,fullfile([matfigroot filesep ...
                'reliable_neural_variance_all_mice.png']));

    saveas(fpa,fullfile([matfigroot filesep ...
                'reliable_neural_and_behav_variance_pooled_across_mice.png']));

    saveas(fpag,fullfile([matfigroot filesep ...
                'reliable_neural_and_behav_variance_pooled_across_good_mice.png']));
end

