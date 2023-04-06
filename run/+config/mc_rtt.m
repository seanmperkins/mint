% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [Settings, HyperParams] = mc_rtt()

% Get some generic settings and hyperparameters.
[Settings, HyperParams] = config.generic();

% Determine which time period of raw data should be loaded on each trial,
% relative to the start of each 'trial'. This should be broad enough to 
% meet all the training needs and provide necessary spiking history for testing.
Settings.trial_alignment = -600:1200; % relative to trial start

% For this dataset, each trial is 600 ms long and is not aligned to
% movement. Thus, the test data should simply be the full 600 ms trial.
Settings.test_alignment = 0:599; % relative to trial start

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Hyperparameters related to learning neural trajectories.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% None - for this dataset, neural trajectories were learned using
% AutoLFADS, which has a built-in mechanism for optimizing its
% hyperparameters.

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
    HyperParams.window_length = 480;
else
    HyperParams.window_length = 920;
end

% Configure interpolation. See 'generic.m' for details regarding these hyperparameters.
HyperParams.n_candidates = 6;
HyperParams.interp_within_trajectories = true;