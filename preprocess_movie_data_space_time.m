%
% Preprocess movie data for space time study
%



% Pick the appropriate data and downsample it
switch par.cam_behavior 

    % use all cameras
    case 'all'	
        M = bin2d(data.motSVD(1:end,:), par.tbin, 1)';
    % just use camera 1
    case 'cam1'
        M = bin2d(data.motSVD1cam(1:end,:), par.tbin, 1)';
end


% De-mean it
M = M - mean(M,2);

% Normalize the magnitude of the PCs
switch par.norm_cams
    case 'sd_pc1'
        % divide by the std of the first component
        M = M / std(M(1,:));
    case '95th_minus_5th'
        % divide by the difference between the 95th and 5th percentile
        error('not implemented yet');
end