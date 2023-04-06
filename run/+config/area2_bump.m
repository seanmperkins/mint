% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [Settings, HyperParams] = area2_bump()

% Get some generic settings and hyperparameters.
[Settings, HyperParams] = config.generic();

% Determine which time period of raw data should be loaded on each trial,
% relative to movement onset. This should be broad enough to meet all the
% training needs and provide necessary spiking history for testing.
Settings.trial_alignment = -700:850;

% Determine which time period should be used to evaluate performance,
% relative to movement onset.
Settings.test_alignment = -100:500;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Hyperparameters related to learning neural trajectories.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set where idealized neural trajectories will begin and end, relative to
% movement onset.
HyperParams.trajectories_alignment = -350:750;

% When smoothing spikes, 'sigma' is the standard deviation of the Gaussian filter.
HyperParams.sigma = 25;

% After learning rates for neural trajectories, one may wish to try to further
% improve those rate estimates. Depending on the data set, it may be beneficial
% to reduce the dimensionality of the rates across neurons, across conditions, 
% or across trials within each condition. A value of NaN means don't reduce
% dimensionality.
HyperParams.n_neural_dims = NaN;
HyperParams.n_cond_dims = NaN;
HyperParams.n_trial_dims = 1; % I only ever use NaN or 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Hyperparameters related to decoding.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The 'causal' hyperparameter is a logical determining whether decoding is
% performed based on a trailing history of spikes (causal = true) or
% decoding is performed based on a spiking window centered around the
% current time (causal = false).
HyperParams.causal = true;

% What bin size to use when decoding. Real-time estimates can still be
% generated at a higher resolution than this - this value just determines
% how frequently you update based on new spiking observations.
HyperParams.Delta = 20;

% Set length of spiking observation window (length of trailing history in
% the case of causal decoding).
if HyperParams.causal
    HyperParams.window_length = 240;
else
    HyperParams.window_length = 560;
end

% Configure interpolation. See 'generic.m' for details regarding these hyperparameters.
HyperParams.n_candidates = 2;
HyperParams.interp_within_trajectories = false;

