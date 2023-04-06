% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function obj = fit(obj, S, Z, condition) %#ok

% Fit idealized trajectories.
[obj.Omega_plus, obj.Phi_plus, obj.behavior_labels] = eval([obj.Settings.task,'.fit_trajectories(S, Z, condition, obj.Settings, obj.HyperParams)']);

% Compute lambdas for each neural state in Omega_tilde.
Lambda = cellfun(@(Omega_plus) bin_data(Omega_plus, obj.Delta, 'mean'), obj.Omega_plus,'un',0);

% Assign an index to each rate in Lambda indicating the
% element of 'rates' that most closely approximates the actual
% rate. This will be used for accessing the correct
% log-probabilities in L during inference.
obj.V = cellfun(@(Lambda) get_rate_indices(Lambda, obj.lambda_range, obj.n_rates), Lambda,'un',0);

% Convert V to a matrix and compute column indices marking 
% the start of each condition in this matrix.
last_idx = cumsum(cellfun(@(V) size(V,2), obj.V));
obj.first_idx = [1; last_idx(1:end-1)+1];
obj.first_tau_prime_idx = sort(reshape(obj.first_idx + (0:obj.tau_prime-1),[],1));
obj.V = cell2mat(obj.V')';

% Generate MEX file to speed up core recursion.
generate_mex(obj.L, obj.V, size(obj.Omega_plus{1},1), obj.tau_prime, obj.first_idx, last_idx);

