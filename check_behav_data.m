%
% Check movie data in some rudimentary ways
%



ctr = 1;

% do
for d = db_use

   
    disp(['Processing spont_' db(d).mouse_name '_' db(d).date]);

    data = load(fullfile(dataroot, ...
        ['spont_' db(d).mouse_name '_' db(d).date]));


    % preprocess movie data
    Mnorm = preprocess_movie_data_space_time( data, par );
    
    % store normalized variance per video PC
    beh_var_expl_norm(ctr,:) = var(Mnorm,1,2);


    % preprocess movie data without normalization
    M = preprocess_movie_data_space_time( data, struct('cam_behavior',par.cam_behavior,...
        'norm_cams','none','tbin',par.tbin));

    % store raw variance per video PC
    beh_var_expl(ctr,:) = var(M,1,2);

    ctr = ctr + 1;
end



% -------------------------------------------------------------------------
%% PLOTS 

% mice-specific colors
cols_mouse = parula(length(db_use)+2);

% make legend
lc = 1;
for d = db_use
    lgnd{lc} = [db(d).mouse_name '_' db(d).date];
    lc = lc + 1;
end


figure, 
subplot(121),hold on
for d = 1:length(db_use)
    plot(beh_var_expl_norm(d,:),'color',cols_mouse(d,:))
end
set(gca,'XScale','log','TickDir','out')
xlabel('Movie dimension'),ylabel('Norm. behavioral variance expl.')
title(['All mice -- movie PCs normalized using ' par.norm_cams],'Interpreter','none')
legend(lgnd,'Location','NorthEast','Interpreter','none'), legend boxoff
xlim([0 size(beh_var_expl,2)/2])

subplot(122),hold on
for d = 1:length(db_use)
    plot(beh_var_expl(d,:),'color',cols_mouse(d,:))
end
set(gca,'XScale','log','TickDir','out')
xlabel('Movie dimension'),ylabel('Behavioral variance explained')
title('All mice -- raw movie PCs')
xlim([0 size(beh_var_expl,2)/2])
legend(lgnd,'Location','NorthEast','Interpreter','none'), legend boxoff





% -------------------------------------------------------------------------
%%
clearvars -except par res* db* dataroot matfig*
