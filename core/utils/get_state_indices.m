% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function k_idx = get_state_indices(k_prime_hats, f, K)

% Convert k_prime_hats using f (which was defined in get_time_indices.m).
k_idx = [f(k_prime_hats(1)); f(k_prime_hats(2))];

% Ensure that k_idx never extends beyond the extent of the learned
% idealized neural trajectories by saturating indices as needed.
k_idx = max(min(k_idx,K),1);
