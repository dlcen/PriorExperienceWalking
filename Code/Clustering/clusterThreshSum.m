% There are two p_crit values in the INPUT variables of the function, in case you want to use a different p_crit value for locating a cluster. 
% 	- p_crit_origin: the p_crit value that was used when clusters were calculated at each t-threshold.
%   - p_crit_alter: the p_crit value that you want to use to locate a cluster, for example, you want to see how close other non-significant clusters are to the p_crit value.
%   - Usually p_crit_alter < p_crit_origin
% 
% OUTPUT:
%   - cluster_no: the number of clusters (significant and close to significanse)
%   - t_thresh: the value of t-threshold at which the cluster(s) are significant (for all clusters there is only ONE t-threshold)
%   - p_vals: p-values of the clusters
%   - cluster_sel: the number of the cluster(s). For example, the significant cluster is the second of all clusters at the t-threshold in the data.
% 
% NOTE:
%   Clusters are meaningless without a t-threshold!
% -----------------------------------------------------------------------------------------------------------------------------------------------------

function [cluster_no, t_thresh, p_vals, cluster_sel] = clusterThreshSum(condition_pair_1, condition_pair_2, p_crit_origin, p_crit_alter) 
	if nargin == 2
		p_crit_origin = 0.05;
		p_crit_alter  = p_crit_origin;
	elseif nargin == 3
		p_crit_alter = p_crit_origin;
	end

	% Get the name of the conditions
	conditions = fields(condition_pair_1);

	% Get the name of the cluster output file
	output_file = ['ClusterResults_', condition_pair_1.(conditions{1}), condition_pair_1.(conditions{2}), '-', condition_pair_2.(conditions{1}), condition_pair_2.(conditions{2}), '_', num2str(p_crit_origin), '.txt'];

	% Read the output file
	delim = {',', ' = '};

	try
		output_data = readtable(output_file, 'delimiter', delim, 'MultipleDelimsAsOne', 1);
	catch ME
		rethrow(ME)
    end
    
    if size(output_data, 1) > 0
        output_data.Properties.VariableNames = {'t_idfier', 't_thresh', 'p_no', 'p'};
    elseif size(output_data, 1) == 0
        cluster_no 	= 0;
		t_thresh 	= [];
		p_vals 		= [];
		cluster_sel = 0;
    end
        
	% Check the output file and find out the significant cluster(s) with a p_value < p_crit_alter
	% If the file only contains one row and the p-value > 0.1, then there is no valid cluster
	if size(output_data, 1) <= 1 
		cluster_no 	= 0;
		t_thresh 	= [];
		p_vals 		= [];
		cluster_sel = 0; % selection of clusters. If this value is 0, means there is only one significant cluster.

	elseif size(output_data, 1) > 1 % There is at least one valid cluster. 
		% Find out whether there is only one cluster or more than one cluster.

		% Obtain the rows with a p value < p_crit_alter
		sig_idx = find(output_data.p < p_crit_alter);
		sig_data = output_data(sig_idx, :);

		% If there is only one row left in the data, it is quite straightforward that this is the t threshold and p value for the cluster.
		if size(sig_data, 1) == 1
			cluster_no 	= 1;
			t_thresh  	= sig_data.t_thresh;
			p_vals     	= sig_data.p;

			% Now there is another question: if there are more than one cluster, then which one is valid?
			if strcmp(sig_data.p_no, 'p value')
				cluster_sel = 0;
			else
				% Get the number from the string
				this_str    = char(sig_data.p_no);
				cluster_sel = sscanf(this_str, 'the %dth p value');
			end

		elseif size(sig_data, 1) > 1
			% Get the smallest value of t threshold
			t_min 	   	= min(sig_data.t_thresh);
			min_idx    	= find(sig_data.t_thresh == t_min);
			sig_data    = sig_data(min_idx, :);

			% If there is only one row left
			if size(sig_data, 1) == 1
				cluster_no = 1;
				t_thresh  = t_min;
				p_vals 	   = sig_data.p;

				if strcmp(sig_data.p_no, 'p value')
					cluster_sel = 0;
				else
					% Get the number from the string
					this_str    = char(sig_data.p_no);
					cluster_sel = sscanf(this_str, 'the %dth p value');
				end

			% If there are more than one row left
			else
				cluster_no  = size(sig_data, 1);
				p_vals      = sig_data.p;

				cluster_sel = zeros(cluster_no, 1);
				for i = 1:cluster_no
					this_str = sig_data.p_no{i};
					cluster_sel(i) = sscanf(this_str, 'the %dth p value');
				end
			end
		
		elseif size(sig_data, 1) == 0
			cluster_no 	= 0;
			t_thresh 	= [];
			p_vals 		= [];
			cluster_sel = 0;
		end

		% Check the output file again and find out if there is any cluster(s) with a p_value > p_crit_alter but very close to it.
		% From the t threshold find the clusters in the output_data
		if length(t_thresh) > 0
			output_data_cut = output_data(output_data.t_thresh == t_thresh, :);

			% If there is more than one row left, means that in addition to the significant cluster, there may be other cluster(s) with a p_value close to p_crit_alter
			if size(output_data_cut, 1) > 1
				% Remove the signficant cluster(s)
				if cluster_no == 1
					sig_cls_idx = find(output_data_cut.p == p_vals);
					output_data_cut(sig_cls_idx, :) = [];
				else
					for n = 1:cluster_no
						sig_cls_idx = find(output_data_cut.p == p_vals(n));
						output_data_cut(sig_cls_idx, :) = [];
					end
				end

				% Let's see what we get after removing all the significant cluster(s)
				% If there is any row(s) left in the output_data_cut, means that there may be some clusters which could have a p value close to p_crit_alter
				if size(output_data_cut, 1) > 0
					other_cluster_no = size(output_data_cut, 1);

					% check through the left clusters
					for m = 1:other_cluster_no
						this_cluster = output_data_cut(m, :);
						
						if this_cluster.p < p_crit_alter * 2 % if the cluster's p value is smaller than twice p_crit_alter, its p value is considered to be very close to p_crit_alter but not significant
							cluster_no = cluster_no + 1;
							p_vals = [p_vals; this_cluster.p];

							this_str = char(this_cluster.p_no);
							cluster_sel = [cluster_sel; sscanf(this_str, 'the %dth p value')];
						end
					end
				end
			end
		end
	end
end
						
		 


