% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

%%% Determine which time indices will have estimates generated at the present iteration of MINT.

function [t_idx, f] = get_time_indices(t_prime, T_prime, T, Delta, tau_prime, causal)

% Convert times to full sampling rate.
t = t_prime*Delta;

% Adjust t if estimating acausally.
if ~causal
    tau = (tau_prime+1)*Delta - 1;
    adjustment = round((tau+1+Delta)/2);
    t = t - adjustment;
end

% Add additional t for the upcoming time steps in which no new
% observations will arrive.
t_idx = t + (0:Delta-1);

% If this is the first time bin for which sufficient spiking history exists...
if t_prime == tau_prime+1
    
    % Prepend t_idx so that estimates will propagate back toward beginning of the trial.
    n_times_to_add = t_idx(1)-1;
    t_idx_pre = 1:n_times_to_add;
    t_idx = [t_idx_pre, t_idx];
    
end

% If this is the last time bin of the trial and t_idx doesn't reach the end of the trial...
if t_prime == T_prime && t_idx(end) < T
    
    % Append t_idx so that the estimates will reach the end of the trial.
    n_times_to_add = T - t_idx(end);
    t_idx_post = t_idx(end) + (1:n_times_to_add);
    t_idx = [t_idx, t_idx_post];
    
end

% Truncate indices if they overrun the end of the trial.
t_idx = t_idx(t_idx <= T);

% Create a function handle that replicate this transformation from t_prime
% to t_idx so it can be applied later to state indices.
f = @(k_prime) (k_prime-t_prime)*Delta + t_idx;
