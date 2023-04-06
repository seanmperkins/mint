% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [S, Z, condition, CondInfo] = get_trial_data(Settings, split)

% Load data.
load(Settings.data_path,'T','TrialInfo')

% Preallocate outputs.
n_trials = height(TrialInfo);
S = cell(n_trials,1);
Z = cell(n_trials,1);
condition = zeros(n_trials,1);

% Get list of conditions.
cond_list = unique([TrialInfo.trial_type TrialInfo.trial_version],'rows');
CondInfo = array2table(cond_list,'VariableNames',{'trial_type','trial_version'});

% Extract each trial.
for tr = 1:n_trials

    % Align to movement onset and extract time-series data.
    t_move = find(T.time == TrialInfo.move_onset_time(tr));
    t_mask = t_move + Settings.trial_alignment;
    S{tr} = [T.heldout_spikes(t_mask,:), T.spikes(t_mask,:)]';
    Z{tr} = [T.hand_pos(t_mask,:), T.hand_vel(t_mask,:)]';
    condition(tr) = find(all(cond_list == [TrialInfo.trial_type(tr) TrialInfo.trial_version(tr)],2));

    % Ensure no data boundaries have been exceeded.
    if any(isnan(Z{tr}),'all')
        error('Data boundaries exceeded.')
    end

end

% Restrict to trials for designated split.
if strcmp(split,'train') % get training trials
    train_idx = strcmp(TrialInfo.split,'train');
    S = S(train_idx);
    Z = Z(train_idx);
    condition = condition(train_idx);
elseif strcmp(split,'test') % get testing trials (which are labeled 'val' in TrialInfo)
    test_idx = strcmp(TrialInfo.split,'val');
    S = S(test_idx);
    Z = Z(test_idx);
    condition = condition(test_idx);
end
