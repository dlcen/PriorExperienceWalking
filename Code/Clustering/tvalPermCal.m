function [tvalues] = tvalPermCal(datA, datB, grpSizeA, grpSizeB, grp_size, permutation_no)
	data_len 		= 100;

	% Whether the two groups have the same sample size
	if grpSizeA == grpSizeB
		same_sample_size = true;
	else
		same_sample_size = false;
    end
    
    if same_sample_size
        p_grp_size  = grpSizeA;
    else
        p_grp_size 		= min([grpSizeA, grpSizeB]);
    end
    
    full_combn_no = nchoosek(p_grp_size, ceil(p_grp_size/2));
    
    if permutation_no < full_combn_no^2
    
        permutation_grp_A = cell2mat(arrayfun(@(dummy) sort(randperm(p_grp_size, ceil(p_grp_size/2))), 1:permutation_no, 'UniformOutput', false)');
        permutation_grp_B = cell2mat(arrayfun(@(dummy) sort(randperm(p_grp_size, ceil(p_grp_size/2))), 1:permutation_no, 'UniformOutput', false)');
 
        permutation_grps  = [permutation_grp_A, permutation_grp_B];
        permutation_grps  = unique(permutation_grps, 'rows');
    
		while size(permutation_grps, 1) < permutation_no
			chs_grp_A = sort(randperm(p_grp_size, ceil(p_grp_size/2)));
			chs_grp_B = sort(randperm(p_grp_size, ceil(p_grp_size/2)));
			chs_grps  = [chs_grp_A, chs_grp_B];
			[l, c]   = ismember(chs_grps, permutation_grps, 'rows');
			if c == 0
				permutation_grps = [permutation_grps; chs_grps];
			end
        end
        
    elseif permutation_no > full_combn_no^2 
        disp('Number of permutation is too large.')
        return 
    end
    
    % Back up datA and datB
    datA_raw = datA;
    datB_raw = datB;

    permutation_grp_A = permutation_grps(:, 1:ceil(p_grp_size/2));
    permutation_grp_B = permutation_grps(:, (ceil(p_grp_size/2) + 1):end);

    perm_thresh     = 50000;
    if permutation_no > perm_thresh
    	permutation_times = ceil(permutation_no/perm_thresh);
    	tvalues 		  = zeros(permutation_no, data_len);
        
    	for p = 1:permutation_times
    		tic
    		this_start 	  = (p - 1) * perm_thresh + 1;
    		if p < permutation_times
    			this_stop = p * perm_thresh;
    		elseif p == permutation_times
    			this_stop = permutation_no;
    		end
    			
    		this_perm_grp_A = permutation_grp_A([this_start:this_stop], :);
    		this_perm_grp_B = permutation_grp_B([this_start:this_stop], :);
    		this_perm_no 	= size(this_perm_grp_A, 1); 

    		datA			= repmat(datA_raw, 1, 1, this_perm_no);
		   	datA 			= permute(datA, [3, 2, 1]);

			p1_A            = repelem(1:this_perm_no, ceil(p_grp_size/2)* data_len);
		    p2_A            = repelem(reshape(this_perm_grp_A', 1, []), data_len);
	        p3_A            = repmat(1:data_len, 1, this_perm_no * ceil(p_grp_size/2));
		    swit_idx_A 		= sub2ind([this_perm_no, p_grp_size, data_len], p1_A, p2_A, p3_A);

		    datB			= repmat(datB_raw, 1, 1, this_perm_no);
			datB 			= permute(datB, [3, 2, 1]);

			p1_B            = repelem(1:this_perm_no, ceil(p_grp_size/2)* data_len);
		    p2_B            = repelem(reshape(this_perm_grp_B', 1, []), data_len);
	        p3_B            = repmat(1:data_len, 1, this_perm_no * ceil(p_grp_size/2));
		    swit_idx_B 		= sub2ind([this_perm_no, p_grp_size, data_len], p1_B, p2_B, p3_B);

		    bkpA 			= datA;

		    datA(swit_idx_A)= datB(swit_idx_B);
		    datB(swit_idx_B)= bkpA(swit_idx_A);

		    [~, ~, ~, stat] = ttest2(datA, datB, 'Dim', 2);
			tvalues([this_start:this_stop], :) 	    = squeeze(stat.tstat);
        end

	else
	   	datA			= repmat(datA_raw, 1, 1, permutation_no);
	   	datA 			= permute(datA, [3, 2, 1]);
		datB			= repmat(datB_raw, 1, 1, permutation_no);
		datB 			= permute(datB, [3, 2, 1]);

	    p1_A            = repelem(1:permutation_no, ceil(p_grp_size/2)* data_len);
	    p2_A            = repelem(reshape(permutation_grp_A', 1, []), data_len);
        p3_A            = repmat(1:data_len, 1, permutation_no * ceil(p_grp_size/2));
	    swit_idx_A 		= sub2ind([permutation_no, p_grp_size, data_len], p1_A, p2_A, p3_A);

	    p1_B            = repelem(1:permutation_no, ceil(p_grp_size/2)* data_len);
	    p2_B            = repelem(reshape(permutation_grp_B', 1, []), data_len);
        p3_B            = repmat(1:data_len, 1, permutation_no * ceil(p_grp_size/2));
	    swit_idx_B 		= sub2ind([permutation_no, p_grp_size, data_len], p1_B, p2_B, p3_B);

	    bkpA 			= datA;

	    datA(swit_idx_A)= datB(swit_idx_B);
	    datB(swit_idx_B)= bkpA(swit_idx_A);

	    [~, ~, ~, stat] = ttest2(datA, datB, 'Dim', 2);
		tvalues 	    = squeeze(stat.tstat);

    end
end

