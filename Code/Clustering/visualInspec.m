function visualInspec(condition_pair_1, condition_pair_2, cluster_no, t_thresh, p_vals, cluster_sel, p_crit_alter, ExpNo)
	% Draw difference (t) plot 

	% Read t-values
	conditions      = fields(condition_pair_1);
	thisComp 		= [condition_pair_1.(conditions{1}), condition_pair_1.(conditions{2}), '-',  condition_pair_2.(conditions{1}), condition_pair_2.(conditions{2})];
	t_file  		= ['tvalues_', thisComp, '.csv'];
	tvalues 		= readtable(t_file);

	if nargin == 7
		ExpNo = '';
	end

	ylim_up 		= 5;
	ylim_down 		= -1;
	x_end 			= 6.5;

	% Plot the figure

	% 1. Plot the t values
	figure;
	plot(tvalues.z, tvalues.t, 'Color', [135/255 206/255 235/255], 'LineWidth', 2)
	hold on
	plot([0, x_end], [0, 0], 'k')

	% 2. Plot the cluster(s)

	if cluster_no > 0
        
		for i = 1:cluster_no
			
            this_p_vals   = p_vals(i);
			this_cls_sel  = cluster_sel(i);

			switch this_cls_sel 
			case 0
                above_threshold 	= find(tvalues.t >= t_thresh);
				cluster_start 		= tvalues.z(min(above_threshold));
				cluster_end 		= tvalues.z(max(above_threshold));
                cluster_peak        = max(tvalues.t(min(above_threshold):max(above_threshold)));

            otherwise
                above_threshold 	= find(tvalues.t >= t_thresh);
                above_diff          = diff(above_threshold);
                cluster_breaks 		= find(above_diff > 1);
                cluster_boundaries  = sort([1; cluster_breaks; (cluster_breaks + 1); length(above_diff)]);
                cluster_boundaries  = reshape(cluster_boundaries, 2, length(cluster_boundaries)/2);
                cluster_distances   = diff(cluster_boundaries);
                clusters            = above_threshold(cluster_boundaries(:, cluster_distances >= 9));
                this_cluster        = clusters(:, this_cls_sel);
                cluster_start       = tvalues.z(this_cluster(1));
                cluster_end 		= tvalues.z(this_cluster(2));
                cluster_peak        = max(tvalues.t(this_cluster(1):this_cluster(2)));
             
			end

		    text_x = (cluster_end + cluster_start) /2;
            text_y = cluster_peak + 0.5 * i;
            
            display_text = ['p = ', num2str(this_p_vals)];
            
            hold on
            text(text_x, text_y, display_text, 'FontSize', 12, 'Color', 'r', 'FontWeight', 'Bold')
            fill([cluster_start, cluster_end, cluster_end, cluster_start, cluster_start], [ylim_up, ylim_up, ylim_down, ylim_down, ylim_up], [.1 .1 .1], 'LineStyle', 'none')
            alpha(0.1)
        end

        % Plot a horizontal line to show t-threshold
        tvalues_n = length(tvalues.t);
        tval_segs = floor(tvalues_n / 3);
        tval_frt  = sum(abs(tvalues.t(1:tval_segs) - t_thresh));
        tval_mdl  = sum(abs(tvalues.t((tval_segs + 1) : tval_segs * 2) - t_thresh));
        tval_end  = sum(abs(tvalues.t((2 * tval_segs + 1) : end) - t_thresh));
        tval_seg_means = [tval_frt, tval_mdl, tval_end];
        t_thresh_text_xs = [0.1, 2.25, 4.25];

        if any(tval_seg_means >= 1)
        	t_thresh_text_x = t_thresh_text_xs(tval_seg_means == max(tval_seg_means(tval_seg_means >= 0.75)));
        else
         	t_thresh_text_x = t_thresh_text_xs(tval_seg_means == max(tval_seg_means));
         end

        if t_thresh > 0.4
        	t_thresh_text_y_offset = -0.25;
        elseif t_thresh >= 0 
        	t_thresh_text_y_offset = 0.25;
        elseif t_thresh >= -0.4
        	t_thresh_text_y_offset = -0.25;
        else 
        	t_thresh_text_y_offset = 0.25;
        end

	    hold on
	    line([0 7], [t_thresh t_thresh], 'Color', [.5 .5 .5], 'LineStyle', '--')
	    t_thresh_text = ['t-threshold = ', num2str(t_thresh)];
	    text(t_thresh_text_x, t_thresh + t_thresh_text_y_offset, t_thresh_text, 'FontSize', 10, 'Color', 'k')

	elseif  cluster_no == 0 % in the case that there is no significant cluster

		no_cluster_display_text = 'No significant cluster was found.';
		hold on
		text(1, 2.5, no_cluster_display_text, 'FontSize', 12, 'Color', 'r', 'FontWeight', 'Bold')
		
    end

	xlim([0, x_end])
	ylim([ylim_down, ylim_up])

	xlabel('Z position (m)', 'FontSize', 14)
	ylabel('Difference (t)', 'FontSize', 14)

    figure_folder = 'Figures';
    if ~exist(figure_folder, 'dir') 
        mkdir(figure_folder) 
    end 
    
    print([figure_folder, filesep, ExpNo, condition_pair_1.(conditions{1}), condition_pair_1.(conditions{2}), '-', condition_pair_2.(conditions{1}), condition_pair_2.(conditions{2}), '_', num2str(p_crit_alter), '.png'], '-dpng') 
	
end