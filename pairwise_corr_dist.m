%
% Computes pairwise correlations and their distributiosn as a funciton of
% distance
%


x_hist_step = par.x_hist_dist_step; % step fr distance histogram (um)
x_hist_max = par.x_hist_dist_max; % close to the max I think

ctr = 1; % for saving the results


tic;

disp(' '); disp('Computing pairwise correlations vs. distance'); disp(' ');


for d = db_use
   
    disp(['Processing spont_' db(d).mouse_name '_' db(d).date]);
    
    data = load(fullfile(dataroot, ...
        ['spont_' db(d).mouse_name '_' db(d).date]));
    
   
    % ---------------------------------------------------------------------
    % Preprocess the data: compute distances, subsample and de-mean
    [X, xc, yc, nc, nt, dist] = preprocess_neural_data_space_time( data, par );
    
       
    
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % Compute pairs-wise correlations
    
    [r, all_r, all_dist] = compute_pairwise_corr(X, dist);

    
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % Find strong correlations
    
    switch par.strong_corr_criterion
        case 'pctile'
            th_r = prctile( abs(all_r), par.pctile_strong_corr );
        case 'threshold'
            th_r = par.thres_strong_corr;
    end
    
    flag_strong_r = abs(all_r) > th_r;
    
    strong_r = all_r(flag_strong_r);
    dist_strong_r = all_dist(flag_strong_r);
    
    
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % comnpute distributions
    
    x_dist = 0 : x_hist_step : x_hist_step*ceil(x_hist_max/x_hist_step);
    
    hist_r_dist = histcounts(all_dist,x_dist)/length(all_dist)*100;
    hist_strong_r_dist = histcounts(dist_strong_r,x_dist)/length(dist_strong_r)*100;
        
    
    
%     figure,hold on
%     plot(x_dist(1:end-1),hist_r_dist,'color',[.6 .6 .6],'linewidth',2)
%     plot(x_dist(1:end-1),hist_strong_r_dist,'color','b','linewidth',2)
%     xlabel('Distance (um)'),ylabel('Probability'),legend('all cells','strong peers')
%     
    
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    % store results
    
    resCorr.r{ctr} = all_r;
    resCorr.dist{ctr} = all_dist;
    
    resCorr.strong_r{ctr} = strong_r;
    resCorr.dist_strong_r{ctr} = dist_strong_r;
    
    resCorr.xhist(ctr,:) = x_dist;
    resCorr.hist_r_dist(ctr,:) = hist_r_dist;
    resCorr.hist_strong_r_dist(ctr,:) = hist_strong_r_dist;
    
    ctr = ctr + 1;
    
    toc;
end


clearvars -except par res* db* dataroot matfig*



% Summary plot
cols_mouse = parula(length(db_use)+2);
cols_all = gray(length(db_use)+2);

figure,hold on
for d = 1:length(db_use)
    plot(resCorr.xhist(d,1:end-1),resCorr.hist_r_dist(d,:),'color',cols_all(d,:),'linewidth',2)
    plot(resCorr.xhist(d,1:end-1),resCorr.hist_strong_r_dist(d,:),'color',cols_mouse(d,:),'linewidth',2)
end
xlabel('Distance (um)'),ylabel('Probability'),
legend('all cells','strong peers'), legend boxoff
set(gca,'TickDir','out')
set(gcf,'color','w')   