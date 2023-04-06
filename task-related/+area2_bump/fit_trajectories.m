% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [Omega_plus, Phi_plus, Phi_labels] = fit_trajectories(S, Z, condition, Settings, HyperParams)

% Smooth spikes with a Gaussian filter.
S_smooth = cellfun(@(spikes) gauss_filt(spikes, HyperParams.sigma, HyperParams.Delta), S,'un',0);

% Preprocess behavioral variables.
[Z, Phi_labels] = area2_bump.preprocess_behavior(Z, Settings);

% Trim smoothed spikes and behavioral variables in time to match desired alignment for trajectories.
t_mask = ismember(Settings.trial_alignment, HyperParams.trajectories_alignment);
S_smooth = cellfun(@(S_smooth) S_smooth(:,t_mask), S_smooth,'un',0);
Z = cellfun(@(Z) Z(:,t_mask), Z,'un',0);

% Reformat smoothed spikes and behavioral variables into a cell array (conditions) of cell arrays (trials).
cond_list = unique(condition);
n_conds = length(cond_list);
X = cell(n_conds,1);
Z_sort = cell(n_conds,1);
for c = 1:length(cond_list)
    tr_mask = condition == cond_list(c);
    X{c} = S_smooth(tr_mask);
    Z_sort{c} = Z(tr_mask);
end

% Compute trial-averaged behavioral variables.
Z_bar = cellfun(@(Zc) mean(cat(3,Zc{:}),3), Z_sort,'un',0);

% Create smooth firing rate averages using dimensionality reduction.
X_bar = smooth_average(X, HyperParams, Settings.Ts);

% Create trajectories according to what you wish to estimate.
Omega_plus = X_bar; % firing rates
Phi_plus = Z_bar;   % kinematics

