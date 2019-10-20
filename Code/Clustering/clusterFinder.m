function [clusters, cluster_sum] = clusterFinder(t_crit, tvalues)
	cluster_idx 	= find(tvalues >= t_crit); 									    % Find those data point with t values greater than the threshold
	step_size 		= 10;						  									% 10 points = 0.55m, about one step

	if isempty(cluster_idx) 						 								% There is no data point where the t value is greater than the threshold
		cluster_sum = []; 
        clusters    = [];
	else
		cluster_seq = diff(cluster_idx);
		cluster_int = find(cluster_seq > 1);	 									% Find potential breaks between clusters. This is quite strict, considering no meaningful cluster would have a small break inside.

		if isempty(cluster_int) 					 								% No break -> there is only one potential cluster
			cluster_size 	= length(cluster_idx);
			if cluster_size >= step_size 											% Make sure that the size of the cluster is larger than one step 
				cluster_sum = sum(tvalues(cluster_idx));
				clusters 	= [cluster_idx(1), cluster_idx(end)]; 
			else
				cluster_sum = [];
				clusters 	= [];
			end
        else
            bump_idx        = sort([1, cluster_int, (cluster_int + 1), length(cluster_seq)]);
            bump_idx        = reshape(bump_idx, 2, length(bump_idx)/2);
            bump_diff       = diff(bump_idx);
            bump_big	    = find(bump_diff >= step_size);
            
            if isempty(bump_big)
                cluster_sum = [];
                clusters    = [];
            else
                bump_big_idx    = bump_idx(:, bump_big);
                clusters    	= cluster_idx(bump_big_idx);
                if numel(clusters) == 2
                    clusters        = clusters';
                end
                cluster_no      = size(clusters, 2);
                
                cluster_sum = zeros(cluster_no, 1);
                for i = 1:cluster_no
                    cluster_sum(i, 1) = sum(tvalues(clusters(1, i) : clusters(2, i)));
                end
            end
		end
	end
end