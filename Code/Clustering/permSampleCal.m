function [pval] = permSampleCal(thisCluster, cluster_sum, new_tvalues)
	permutation_no  = size(new_tvalues, 1);
	data_len 		= size(new_tvalues, 2);

	if length(thisCluster) == 2
		thisCluster_seq	= [thisCluster(1) : thisCluster(2)];
	else
		thisCluster_seq = thisCluster;
	end

	cluster_size    = length(thisCluster_seq);
	cluster_mat 	= repmat(thisCluster_seq, permutation_no, 1);
	intrv 			= data_len * [0 : (permutation_no - 1)];
	intrv 			= repmat(intrv, cluster_size, 1);
	cluster_smp_idx = cluster_mat' + intrv;
    new_tvalues     = transpose(new_tvalues);
	cluster_tval 	= new_tvalues(cluster_smp_idx);
	cluster_smp_sum = sum(cluster_tval, 1);
	standout 		= find(abs(cluster_smp_sum) >= cluster_sum);
	pval 			= length(standout)/permutation_no;