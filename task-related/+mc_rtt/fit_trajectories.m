% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [Omega_plus, Phi_plus, Phi_labels] = fit_trajectories(~, Z, ~, Settings, HyperParams)

% Preprocess behavioral variables.
[Vel, Phi_labels] = mc_rtt.preprocess_behavior(Z, Settings);

% Unpack AutoLFADS rates from Z.
Rates = cellfun(@(Z) Z(5:end,:), Z,'un',0);

% Convert rates from units of spikes/second to units of spikes/bin.
Rates = cellfun(@(Rates) Rates*Settings.Ts*HyperParams.Delta, Rates,'un',0);

% Create trajectories according to what you wish to estimate.
Omega_plus = Rates;
Phi_plus =   Vel;

