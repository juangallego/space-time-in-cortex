%
% Predict neural activity (PCs) from behavior. Taken from Stringer
% Pachitariu et al Science 2019
%

function res = pred_neural_from_behav( X, M, par )


    % How many neural PCs to use
    nc = size(X,1);
    % nPCs = max( par.nPC( par.nPC < (nc/2) ) );
    nPCs = par.n_neuralPCs_from_behav;

    
    % do for each delay
    for de = 1:length(par.delay_behav_neural)

        % Delay data in time
        Xd = X(:,1+par.delay_behav_neural(de):end);

        Md = M(:,1:end-par.delay_behav_neural(de));

        ntd = size(Xd,2);
        

        % Split neurons into training and testing sets (half and half)
        nrand = randperm(nc);

        cells_train = nrand(1:floor(nc/2));
        cells_test = nrand(ceil(nc/2)+1:end);


        % Split time bins into training and testing sets
        [idx_train, idx_test] = splitInterleaved(ntd, par.Lblock, ...
            par.fractrain_behav_neural, 1);


        % Estimate the left and right eigenvectors of the cross-cov matrix
        % U and V defined the dominant components of the training and
        % testing neurons ----I think
        [~, ~, U, V] = SVCA(X, nPCs, cells_train, cells_test, ...
            idx_train, idx_test);
        

%         % double check the output of SVCA
%         cov_train = X(cells_train,idx_train) * X(cells_test,idx_train)';
%         [Ut, ~, Vt] = svdecon(cov_train);
%         Ut = Ut(:,1:nPCs);
%         Vt = Vt(:,1:nPCs);
%         figure,subplot(121),imagesc((U-Ut)~=0),subplot(122),imagesc((V-Vt)~=0),colorbar
        

        % -----------------------------------------------------------------
        % Train models

        % Model that predicts training neurons from behavior
        [a_train, b_train] = CanonCor2( Xd(cells_train,idx_train)' * U, ...
                                        M(:,idx_train)', ...
                                        par.lambda_neural_behav );

        % Model that predicts testing neurons from behavior
        [a_test, b_test] = CanonCor2( Xd(cells_test,idx_train)' * V, ...
                                        M(:,idx_train)', ...
                                        par.lambda_neural_behav );


        % -----------------------------------------------------------------
        % Predict neural activity using an increasing number of movie PCs

        ctr = 1;

        for pc = par.n_behavPC

            % Use models trained on training bins based on training and
            % testing neurons to predict testing bins
            pred_train = a_train(:,1:pc) * b_train(:,1:pc)' * Md(:,idx_test);
            pred_test = a_test(:,1:pc) * b_test(:,1:pc)' * Md(:,idx_test);

            % Get actual data: project neural activity onto PCs
            actual_train = U' * X(cells_train,idx_test);
            actual_test = V' * X(cells_test,idx_test);
            
            % Prediction error:
            unexpl_train = actual_train - pred_train;
            unexpl_test = actual_test - pred_test;

            % Compute reliable shared variance unexplained
            shared_unexpl_var = sum( unexpl_train .* unexpl_test, 2);
            tot_unexpl_var = sum( actual_train.^2 + actual_test.^2, 2) / 2;


            % Store results
            res.cov_res_beh(:,ctr) = gather_try(shared_unexpl_var);
			res.var_beh(:,ctr) = gather_try(tot_unexpl_var);
                        
%             cp = 1:4;
%             for c = cp
%                 figure
%                 subplot(211), hold on
%                 plot(X_actual_train(cp(c),:),'k'),plot(X_pred_train(cp(c),:),'r')
%                 title(['Training cell ' num2str(cp(c))])
%                 subplot(212), hold on
%                 plot(X_actual_test(cp(c),:),'k'),plot(X_pred_test(cp(c),:),'r')
%                 title(['Testing cell ' num2str(cp(c))])
%             end
%             
%             for el = 1:2
%                 figure
%                 subplot(121), hold on
%                 plot(pred_train(el,:))
%                 plot(pred_test(el,:),'linestyle','-.')
%                 title(['v_p train vs v_p test -- Component ' num2str(el)])
%                 subplot(122), hold on
%                 plot(X_pred_train(el,:))
%                 plot(X_pred_test(el,:),'linestyle','-.')
%                 title(['s1 vs s2 -- Neuron ' num2str(el)])
%             end

            ctr = ctr + 1;
        end
        
    end
end