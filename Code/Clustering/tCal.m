% Calculate t-values and then export them as .csv files

function tCal(condition_pair_1, condition_pair_2)
	seg_trial_mean  = readtable('segData_trialMean.csv');

	z 				= unique(seg_trial_mean.seg_z);
	data_len 	 	= length(z);

	conditions      = fields(condition_pair_1);

	grpIdxA 		= find(strcmp(seg_trial_mean.(conditions{1}), condition_pair_1.(conditions{1})) & strcmp(seg_trial_mean.(conditions{2}), condition_pair_1.(conditions{2})));
	groupA   		= seg_trial_mean(grpIdxA, :);
	grp_size_A 		= length(unique(groupA.SubjectNo));
	datA 			= reshape(groupA.headingErr, data_len, grp_size_A);

	grpIdxB 		= find(strcmp(seg_trial_mean.(conditions{1}), condition_pair_2.(conditions{1})) & strcmp(seg_trial_mean.(conditions{2}), condition_pair_2.(conditions{2})));
	groupB   		= seg_trial_mean(grpIdxB, :);
	grp_size_B 		= length(unique(groupB.SubjectNo));
	datB 			= reshape(groupB.headingErr, data_len, grp_size_B);

	[~, ~, ~, stat] = ttest2(datA', datB');
	tvalues 		= stat.tstat;

	thisComp 		= [condition_pair_1.(conditions{1}), condition_pair_1.(conditions{2}), '-',  condition_pair_2.(conditions{1}), condition_pair_2.(conditions{2})];

	thisPair 			= [];
	thisPair.Comparison = repmat({thisComp}, data_len, 1);
	thisPair.t 			= tvalues';
	thisPair.z 			= z;
	Tbl 				= struct2table(thisPair);

	writetable(Tbl, ['tvalues_', thisComp, '.csv'])
end


