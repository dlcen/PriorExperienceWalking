function [new_tvalues, tvalues] = permVectCal(condition_pair_1, condition_pair_2, permutation_no)

	%% Prepare the data
	seg_trial_mean 	= readtable('segData_trialMean.csv');
    
    seg_z           = unique(seg_trial_mean.seg_z);
    data_len 		= length(seg_z);

	conditions = fields(condition_pair_1);

	% Choose two groups to be compared
	grpIdxA 	  	= find(strcmp(seg_trial_mean.(conditions{1}), condition_pair_1.(conditions{1})) & strcmp(seg_trial_mean.(conditions{2}), condition_pair_1.(conditions{2})));
	groupA 		  	= seg_trial_mean(grpIdxA, :);
	grpSizeA        = size(groupA, 1)/data_len;
	datA 			= reshape(groupA.headingErr, data_len, grpSizeA);

	grpIdxB 		= find(strcmp(seg_trial_mean.(conditions{1}), condition_pair_2.(conditions{1})) & strcmp(seg_trial_mean.(conditions{2}), condition_pair_2.(conditions{2})));
	groupB			= seg_trial_mean(grpIdxB, :);
	grpSizeB 		= size(groupB, 1)/data_len;
	datB 			= reshape(groupB.headingErr, data_len, grpSizeB);

    grp_size        = grpSizeA + grpSizeB;

	%% Calculate the t-values
	[~, ~, ~, stat] = ttest2(datA', datB');
	tvalues         = stat.tstat; % Calculate the t values along the distance
    
	clearvars seg_trial_mean groupA groupB grpIdxA grpIdxB 

	%% Vectorization 
	switch nargin
		case 2
			permutation_no  =  1000;
	end

	new_tvalues  =  tvalPermCal(datA, datB, grpSizeA, grpSizeB, grp_size, permutation_no);

	
