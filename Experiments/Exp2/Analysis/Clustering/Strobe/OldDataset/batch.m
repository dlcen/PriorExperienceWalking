clear all;

condition_pair_1 = struct('DisplayMode', 'Continuous', 'Familiarity', 'Unfamiliar');
condition_pair_2 = struct('DisplayMode', 'Continuous', 'Familiarity', 'Familiar');

p_crit_origin = 0.1;

[new_tvalues, tvalues] = permVectCal(condition_pair_1, condition_pair_2, 25000);
clusterThreshCal(tvalues, new_tvalues, condition_pair_1, condition_pair_2, p_crit_origin);

tCal(condition_pair_1, condition_pair_2)

p_crit_alter = 0.1;
[cluster_no, t_thresh, p_vals, cluster_sel] = clusterThreshSum(condition_pair_1, condition_pair_2, p_crit_origin, p_crit_alter)
visualInspec(condition_pair_1, condition_pair_2, cluster_no, t_thresh, p_vals, cluster_sel, p_crit_alter, 'Dark_')


clear all;

condition_pair_1 = struct('DisplayMode', 'Intermittent', 'Familiarity', 'Unfamiliar');
condition_pair_2 = struct('DisplayMode', 'Intermittent', 'Familiarity', 'Familiar');

p_crit_origin = 0.1;

[new_tvalues, tvalues] = permVectCal(condition_pair_1, condition_pair_2, 25000);
clusterThreshCal(tvalues, new_tvalues, condition_pair_1, condition_pair_2, p_crit_origin);

tCal(condition_pair_1, condition_pair_2)

p_crit_alter = 0.05;
[cluster_no, t_thresh, p_vals, cluster_sel] = clusterThreshSum(condition_pair_1, condition_pair_2, p_crit_origin, p_crit_alter)
visualInspec(condition_pair_1, condition_pair_2, cluster_no, t_thresh, p_vals, cluster_sel, p_crit_alter, 'Dark_')


clear all;

condition_pair_1 = struct('Familiarity', 'Familiar', 'DisplayMode', 'Intermittent');
condition_pair_2 = struct('Familiarity', 'Familiar',   'DisplayMode', 'Continuous');

p_crit_origin = 0.1;

[new_tvalues, tvalues] = permVectCal(condition_pair_1, condition_pair_2, 25000);
clusterThreshCal(tvalues, new_tvalues, condition_pair_1, condition_pair_2, p_crit_origin);

tCal(condition_pair_1, condition_pair_2)

p_crit_alter = 0.05;
[cluster_no, t_thresh, p_vals, cluster_sel] = clusterThreshSum(condition_pair_1, condition_pair_2, p_crit_origin, p_crit_alter)
visualInspec(condition_pair_1, condition_pair_2, cluster_no, t_thresh, p_vals, cluster_sel, p_crit_alter, 'Dark_')

clear all;

condition_pair_1 = struct('Familiarity', 'Unfamiliar', 'DisplayMode', 'Intermittent');
condition_pair_2 = struct('Familiarity', 'Unfamiliar',   'DisplayMode', 'Continuous');

p_crit_origin = 0.1;

[new_tvalues, tvalues] = permVectCal(condition_pair_1, condition_pair_2, 25000);
clusterThreshCal(tvalues, new_tvalues, condition_pair_1, condition_pair_2, p_crit_origin);

tCal(condition_pair_1, condition_pair_2)

p_crit_alter = 0.05;
[cluster_no, t_thresh, p_vals, cluster_sel] = clusterThreshSum(condition_pair_1, condition_pair_2, p_crit_origin, p_crit_alter)
visualInspec(condition_pair_1, condition_pair_2, cluster_no, t_thresh, p_vals, cluster_sel, p_crit_alter, 'Dark_')



