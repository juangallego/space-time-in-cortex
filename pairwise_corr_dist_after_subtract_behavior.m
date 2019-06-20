%
% Computes pairwise correlations and their distributiosn as a funciton of
% distance
%


x_hist_dist_step = par.x_hist_dist_step; % step fr distance histogram (um)
x_hist_dist_max = par.x_hist_dist_max; % close to the max I think

x_hist_r_step = par.x_hist_corr_step;
x_hist_r_max = par.x_hist_corr_max;


ctr = 1; % for saving the results


tic;

disp(' '); disp('Computing pairwise correlations vs. distance after subtracting behavior subspace'); disp(' ');


for d = db_use
   
    disp(['Processing spont_' db(d).mouse_name '_' db(d).date]);
    
    data = load(fullfile(dataroot, ...
        ['spont_' db(d).mouse_name '_' db(d).date]));
    
    % [nc, nt] = size(data.S)
        


    % ---------------------------------------------------------------------
    % Preprocess the data: compute distances, subsample and de-mean -> X
    [X, xc, yc, nc, nt] = preprocess_neural_data_space_time( data, par );
    
    
    % Preprocess movie data: de-mean and normalize magnitude of PCs -> M
    M = preprocess_movie_data_space_time( data, par );
    

    % ---------------------------------------------------------------------
    % Do PCA of neural data
    
    [PCs, scores, var_expl] = pca_neural(X,par);
    
    
%     % plot variance explained
%     figure,plot(cumsum(var_expl)/sum(var_expl)), ylim([0 1]), xlim([0 500])


    % ---------------------------------------------------------------------
    % Subtract activity in behavior subspace
    
    % *** by detaul this function z-scores the data which I guess makes
    % sense because signals may have different magnitude? *****
    [X_noM, U_xm] = subtract_behavior_subspace( X, M, par );
    
    % [PCs_noM, scores_noM, var_expl_noM] = pca_neural(X_noM,par);
    
    
    % ---------------------------------------------------------------------
    % Compute pairwise correlation between cells before and after
    % subtracting the movement-related activity
    
    [r, all_r, all_dist] = compute_pairwise_corr(X, dist);

    [r_noM, all_r_noM] = compute_pairwise_corr(X_noM, dist);
    
    
    % ---------------------------------------------------------------------
    % Compute statistics
    
    % Corr distribution before and after subtracting faces
    x_hist_r = -x_hist_r_max:x_hist_r_step:x_hist_r_max;
    x_hist_abs_r = 0:x_hist_r_step:x_hist_r_max;
    
    n_hist = numel(all_r);
    
    hist_r = histcounts(all_r,x_hist_r)/n_hist;
    hist_r_noM = histcounts(all_r_noM,x_hist_r)/n_hist;
    
    hist_abs_r = histcounts(abs(all_r),x_hist_abs_r)/n_hist;
    hist_abs_r_noM = histcounts(all_r_noM,x_hist_abs_r)/n_hist;
    
    % Corr vs distance distribution before and after subtracting faces
    x_hist_dist = 0:x_hist_dist_step:x_hist_dist_max;
    x_hist_r_2d = -1:x_hist_r_step*2:1;

    [hist_dist_r, c_hist_dist_r] = hist3([all_dist', all_r'],'Edges',{x_hist_dist x_hist_r_2d});
    hist_dist_r = log( hist_dist_r/n_hist );

    [hist_dist_r_noM, c_hist_dist_r_noM] = hist3([all_dist', all_r_noM'],'Edges',{x_hist_dist x_hist_r_2d});
    hist_dist_r_noM = log( hist_dist_r_noM/n_hist );

    
    
    % ---------------------------------------------------------------------
    % Plot for each dataset
    
    if par.plot_interm
        
        fh = figure('Units','Normalized','OuterPosition',[0 0 1 1]);
        % corr vs corr no-behavior
        subplot(241),hold on
        hc = scatter(all_r,all_r_noM,'.k');
        hc.MarkerFaceAlpha = 0.2;
        hc.MarkerEdgeAlpha = 0.2;
        hc.SizeData = 12;
    %     xl = xlim; yl = ylim; xlim([min(xl(1),yl(1)), max(xl(2),yl(2))]), ...
    %         ylim([min(xl(1),yl(1)), max(xl(2),yl(2))])
        plot([-.5 1],[-.5 1],'linestyle','-.','linewidth',2,'color',[.6 .6 .6])
        axis square, xlim([-.5 1]),ylim([-.5 1])
        xlabel('Corr'),ylabel('Corr after behavior-subtraction')
        title([db(d).mouse_name '_' db(d).mouse_type '_' db(d).date],'Interpreter','none')
        % Corr vs dist
        subplot(242),hold on
        hr = scatter(all_dist,all_r,'.b');
        hrn = scatter(all_dist,all_r_noM,'.c');
        xlabel('Distance (um)'),ylabel('Correlation')
        hrn.MarkerFaceAlpha = 0.2;
        hrn.MarkerEdgeAlpha = 0.2;
        hrn.SizeData = 12;
        hr.MarkerFaceAlpha = 0.2;
        hr.MarkerEdgeAlpha = 0.2;
        hr.SizeData = 12;
        legend('Raw data','Mov-subtracted'), legend boxoff        
        % Distribution of correlations pre-subtracting mov
        subplot(243),
        imagesc(c_hist_dist_r{1},c_hist_dist_r{2},hist_dist_r')
        xlim([0 max(all_dist)]), ylim([-.5 1])
        xlabel('Distance (um)'), ylabel('Corr')
        hcb_hdr = colorbar; title(hcb_hdr,'log(probability)')
        set(gca,'YDir','normal')
        % Distribution of correlations after subtracting mov
        subplot(244),
        imagesc(c_hist_dist_r_noM{1},c_hist_dist_r_noM{2},hist_dist_r_noM')
        hcb_hdrn = colorbar; title(hcb_hdrn,'log(probability)')
        xlim([0 max(all_dist)]), ylim([-.5 1])
        set(gca,'YDir','normal')
        xlabel('Distance (um)'), ylabel('Corr after behavior-subraction')
            
        % abs( corr vs corr ) no-behavior
        subplot(245),hold on
        hca = scatter(abs(all_r),abs(all_r_noM),'.k');
        hca.MarkerFaceAlpha = 0.2;
        hca.MarkerEdgeAlpha = 0.2;
        hca.SizeData = 12;
        plot([0 1],[0 1],'linestyle','-.','linewidth',2,'color',[.6 .6 .6])
        axis square, xlim([0 1]),ylim([0 1])
        xlabel('abs(Corr)'),ylabel('abs(Corr after behavior-subtraction)')
        % abs( corr vs dist )
        subplot(246), hold on
        hra = scatter(all_dist,abs(all_r),'.b');
        hrna = scatter(all_dist,abs(all_r_noM),'.c');
        xlabel('Distance (um)'),ylabel('abs(Correlation)')
        hrna.MarkerFaceAlpha = 0.2;
        hrna.MarkerEdgeAlpha = 0.2;
        hrna.SizeData = 12;
        hra.MarkerFaceAlpha = 0.2;
        hra.MarkerEdgeAlpha = 0.2;
        hra.SizeData = 12;
        % abs( Distribution of correlations pre- and post subtracting mov )
        subplot(247),hold on
        plot(x_hist_abs_r(1:end-1),hist_abs_r,'linewidth',2,'color','b')
        plot(x_hist_abs_r(1:end-1),hist_abs_r_noM,'linewidth',2,'color','c')
        xlim([0 .5])
        xlabel('Correlation'), ylabel('Probability')
        legend('Raw data','Mov-subtracted'), legend boxoff    
        % Sorted correlations
        subplot(248),hold on
        plot(sort(abs(all_r),'descend'),'linewidth',2,'color','b')
        plot(sort(abs(all_r_noM),'descend'),'linewidth',2,'color','c')
        set(gca,'xscale','log')
        xlabel('Cell pair (sorted by decresaing corr)'), ylabel('Correlation')
        legend('Raw data','Mov-subtracted'), legend boxoff    
        
        
        % ------------------------------------
        % OTHER PLOTS
        
        % Sorted correlations before and after subtracting movement
        % subspace
%         [sorted_all_r, idx_sar] = sort(abs(all_r),'descend');
%         figure,hold on
%         plot(sorted_all_r,'b','linewidth',2)
%         plot(abs(all_r_noM(idx_sar)),'c','linewidth',2)
%         set(gca,'xscale','log')
        
        
        if par.save_figs
            saveas(fh,fullfile([matfigroot filesep ...
                db(d).mouse_name '_' db(d).mouse_type '_' db(d).date ...
                '_corr_vs_corr_no_mov.png']));
        end
    end
    
end


% clearvars -except par res* db* data* matfig*