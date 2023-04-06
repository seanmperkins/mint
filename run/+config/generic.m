% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [Settings, HyperParams] = generic()

%%% This function sets some generic settings and hyperparameters that
%%% are unlikely to need adjustment for different tasks/datasets. Of 
%%% course, some of these would need to be changed under certain
%%% circumstances (e.g. Ts would need to be adjusted if the data 
%%% wasn't collected at millisecond resolution), but for now I've
%%% sequestered these here to improve readability of the main config
%%% file, which contains hyperparameters one may wish to play around
%%% with more often.

% Get task name.
st = dbstack(1);
Settings.task = st(1).name;

% Get relevant file paths.
filepath = mfilename('fullpath');
Settings.data_path = [filepath(1:strfind(filepath,'/run/')),'data/',Settings.task,'.mat'];
Settings.results_path = [filepath(1:strfind(filepath,'/+config/')),'results/'];

% Sampling period (seconds/sample) for data.
Settings.Ts = .001;

% Set a hyperparameter for soft-normalization. This comes into play in the
% function 'smooth_average', which cleans up rate estimates during
% training by smoothing across neurons, conditions, or trials. As part of
% that smoothing, PCA is run, and as a preprocessing step for PCA we 
% soft-normalize the firing rates using this hyperparameter.
HyperParams.soft_norm = 5; % spikes/second

% Set the minimum allowable probability of observing any spike count from a
% given neuron. This helps make inference more robust to a briefly erroneous
% spiking pattern (e.g. due to artifact).
HyperParams.min_prob = 1e-6;

% When computing likelihoods based on a Poisson model of spiking, we don't
% let the rate parameter go any lower than min_lambda (spikes/second).
HyperParams.min_lambda = 1;

% When generating a neural state estimate, we don't let the estimated rate
% for any neuron drop below this value (spikes/second). This matters if, 
% for example, you're computing bits-per-spike where estimating a rate of 
% zero (or a very tiny rate), but then seeing a spike, dramatically influences
% the metric. In most cases, this can just remain at zero.
HyperParams.min_rate = 0;

% The 'interp' hyperparameter determines how interpolation is performed.
% The following choices can be made:
%       0: choose the most probable neural state along any trajectory
%          (i.e. don't interpolate)
%       1: choose the most probable neural state and then interpolate
%          across adjacent indices (the state one time bin ahead or
%          behind on the same trajectory)
%       2: choose multiple candidate states (2 or more), interpolate each 
%          across adjacent indices, then interpolate pairwise between
%          these states
%
% You'll almost always prefer interp = 2 because it allows generalization
% between similar behaviors (i.e. interpolation can occur across
% conditions/behaviors).
% 
% If you choose, interp = 2, you need to also specify the number of
% candidates to use (n_candidates) and whether candidates can be selected
% from different locations along the same trajectory or whether they have
% to be selected from different trajectories (interp_within_trajectories).
% Additionally, if interp_within_trajectories = true, you need to specify
% how close two candidate states can be along the same trajectory
% (min_k_dist). Each of these are given default values below, but can be
% overwritten in the main config files.
%
% Note: if interp_within_trajectories = false, the number of candidate
% states cannot be set to a value larger than the number of trajectories
% that will be learned without triggering an error.
HyperParams.interp = 2;
HyperParams.n_candidates = 2;
HyperParams.interp_within_trajectories = false;
HyperParams.min_k_dist = 1000; % since Ts = .001, this means two candidate states can't be within 1 second of one another along the same trajectory

