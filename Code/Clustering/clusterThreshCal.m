function clusterThreshCal(tvalues, new_tvalues, condition_pair_1, condition_pair_2, p_crit)
	if nargin == 4
		p_crit   = 0.01;
	end

	% Get the name of the conditions
	conditions = fields(condition_pair_1);
			
	%% Fisrt check whether there is any valid cluster
	%  Get the 9 largest values (continuous) and check whether the chance of sum is smaller than 0.05
	tvalues_sorted  = sort(tvalues, 'descend');
    init_step       = 10; % this is about 0.55m, average length of a step for walking at a normal speed
	tip_cluster 	= tvalues_sorted(1:init_step);

	%  Check whether there is any valid cluster
	bottomLine 		= min(tip_cluster);
	[cst, cst_sum]  = clusterFinder(bottomLine, tvalues);
    
    if isempty(cst)
        thisBottom  = init_step + 1;
        while isempty(cst) && thisBottom <= 100
            tip_cluster 	= tvalues_sorted(1:thisBottom);
            bottomLine 		= min(tip_cluster);
            [cst, cst_sum]  = clusterFinder(bottomLine, tvalues);
            thisBottom      = thisBottom + 1;
        end
    else
        thisBottom = init_step;
    end
	
	clusters    = cst;
	cluster_sum = cst_sum;
	pval 		= permSampleCal(clusters, cluster_sum, new_tvalues);

	if pval > p_crit * 2 % just in case the p_value of the peak cluster is larger than those clusters with a lower t-threshold. This does not often happen but just in case.
		disp(['ClusterResults_', condition_pair_1.(conditions{1}), condition_pair_1.(conditions{2}), '-', condition_pair_2.(conditions{1}), condition_pair_2.(conditions{2})])
		disp(['Peak p value = ', num2str(pval), ' at t-value = ', num2str(bottomLine), '. No valid clusters found!'])
        
        fid = fopen(['ClusterResults_', condition_pair_1.(conditions{1}), condition_pair_1.(conditions{2}), '-', condition_pair_2.(conditions{1}), condition_pair_2.(conditions{2}), '_', num2str(p_crit), '.txt'],'wt');
        fprintf(fid, ['At t-value = ', num2str(bottomLine), ', p value = ', num2str(pval), '. No valid clusters found!\n']);
        fclose(fid)
        
	else
		disp(['Peak p value = ', num2str(pval)])
		fid = fopen(['ClusterResults_', condition_pair_1.(conditions{1}), condition_pair_1.(conditions{2}), '-', condition_pair_2.(conditions{1}), condition_pair_2.(conditions{2}), '_', num2str(p_crit), '.txt'],'wt');

		while min(pval) <= p_crit && thisBottom <= 100
            
			t_thred 				= min(tvalues_sorted(1:thisBottom));
            
            if t_thred <= 0
                break
            end
            
			[clusters, cluster_sum] = clusterFinder(t_thred, tvalues);

			if length(clusters) > 0
				cluster_no 				= length(cluster_sum);
				if cluster_no == 1
					pval 				= permSampleCal(clusters, cluster_sum, new_tvalues);
					disp(['At t-value = ', num2str(t_thred), ', p value = ', num2str(pval)])
					fprintf(fid, ['At t-value = ', num2str(t_thred), ', p value = ', num2str(pval), '\n']);
				else
					tmp   = zeros(cluster_no, 1);
					for i = 1:cluster_no
						pval 			= permSampleCal(clusters(:, i), cluster_sum(i), new_tvalues);
						disp(['At t-value = ', num2str(t_thred), ', the ', num2str(i), 'th p value = ', num2str(pval)])
						fprintf(fid, ['At t-value = ', num2str(t_thred), ', the ', num2str(i), 'th p value = ', num2str(pval), '\n']);
						tmp(i) 			= pval;
					end
					pval  = min(tmp);
	            end
	            
	            thisBottom              = thisBottom + 1;

	        elseif length(clusters) == 0
	        	thisBottom              = thisBottom + 1;
	        end
	        	
		end

		fclose(fid)
	end
end


