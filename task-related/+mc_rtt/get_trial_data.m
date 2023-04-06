% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [S, Z, condition, CondInfo] = get_trial_data(Settings, split)

% Load data.
load(Settings.data_path,'T','TrialInfo')

% Restrict to trials for designated split. This code block assumes the
% training and testing portions of the data are two separate sections and
% are not interleaved.
if strcmp(split,'train') % get training trials
    last_train_trial = find(strcmp(TrialInfo.split,'train'),1,'last');
    end_time = TrialInfo{last_train_trial,'end_time'};
    T = T(T.time <= end_time,:);
    TrialInfo = TrialInfo(1:last_train_trial,:);
elseif strcmp(split,'test') % get testing trials (which are labeled 'val' in TrialInfo)
    first_val_trial = find(strcmp(TrialInfo.split,'val'),1,'first');
    start_time = TrialInfo{first_val_trial+2,'start_time'}; % start on the 3rd val trial, this is intended to match the test set used in the manuscript, in which the Wiener filter we compared to required a long history that the first two val trials lacked
    T = T(T.time >= start_time,:);
    TrialInfo = TrialInfo(first_val_trial+2:end,:); % start on 3rd val trial
end
TrialInfo.split = [];

% Extract data.
if strcmp(split,'train')

    % Given that trials in this dataset are adjacent to one another,
    % extract training data in long, continuous segments where the only
    % gaps are due to recording gaps.
    [S, Z, condition, CondInfo] = get_continuous_data(T);
    
elseif strcmp(split,'test')

    % Extract test data in trialized format (600 ms plus any needed spiking history).
    [S, Z, condition, CondInfo] = get_trialized_data(T, TrialInfo, Settings);

end

end

function [S, Z, condition, CondInfo] = get_continuous_data(T)

% Identify recording gaps or gaps in AutoLFADS rates. (This code assumes you're not starting or ending in a gap).
gap_mask = isnan(T.finger_pos(:,1)) | isnan(T.autolfads_rates(:,1));
segment_start = [1; find(diff(gap_mask) == -1)+1];
segment_end = [find(diff(gap_mask) == 1); length(gap_mask)];
n_segments = length(segment_start);

% Preallocate outputs.
S = cell(n_segments,1);
Z = cell(n_segments,1);

% Declare each segment its own "condition".
condition = (1:n_segments)';
CondInfo = array2table(unique(condition),'VariableNames',{'condition'});

% Extract each segment.
for i = 1:n_segments

    % Create mask for all segment indices.
    t_mask = segment_start(i):segment_end(i);

    % Extract spikes, kinematics, and AutoLFADS rates (will be used in training).
    S{i} = [T.heldout_spikes(t_mask,:), T.spikes(t_mask,:)]';
    Z{i} = [T.finger_pos(t_mask,1:2), T.finger_vel(t_mask,:), T.autolfads_rates(t_mask,:)]';

end

end

function [S, Z, condition, CondInfo] = get_trialized_data(T, TrialInfo, Settings)

% Preallocate outputs.
n_trials = height(TrialInfo);
S = cell(n_trials,1);
Z = cell(n_trials,1);

% Declare each trial its own "condition".
condition = (1:n_trials)';
CondInfo = array2table(unique(condition),'VariableNames',{'condition'});

% Extract each trial.
for tr = 1:n_trials

    % Align to 'trial' start and extract time-series data.
    t_start = find(T.time == TrialInfo.start_time(tr));
    t_mask = t_start + Settings.trial_alignment;

    % If time window extends before or after the entirety of the data set,
    % make note of how much so we can pad with NaNs.
    if t_mask(1) < 1
        pre_len = sum(t_mask < 1);
        t_mask = t_mask(t_mask >= 1);
    else
        pre_len = 0;
    end
    if t_mask(end) > height(T)
        post_len = sum(t_mask > height(T));
        t_mask = t_mask(t_mask <= height(T));
    else
        post_len = 0;
    end

    % Extract spikes, kinematics, and AutoLFADS rates (will just be NaNs for test data).
    S{tr} = [T.heldout_spikes(t_mask,:), T.spikes(t_mask,:)]';
    Z{tr} = [T.finger_pos(t_mask,1:2), T.finger_vel(t_mask,:), T.autolfads_rates(t_mask,:)]';
    if pre_len > 0
        S{tr} = [NaN(size(S{tr},1), pre_len), S{tr}];
        Z{tr} = [NaN(size(Z{tr},1), pre_len), Z{tr}];
    end
    if post_len > 0
        S{tr} = [S{tr}, NaN(size(S{tr},1), post_len)];
        Z{tr} = [Z{tr}, NaN(size(Z{tr},1), post_len)];
    end

end

end
