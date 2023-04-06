% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function v = get_rate_indices(lambda, lambda_range, n_rates)

% Saturate lambda at lower and upper limits.
lambda_min = lambda_range(1);
lambda_max = lambda_range(2);
lambda = min(max(lambda,lambda_min),lambda_max);

% Convert from rates to indices.
v = (lambda - lambda_min) / diff(lambda_range) * (n_rates - 1) + 1; % +1 is to convert from zero-indexed to one-indexed

% Round and convert to uint16.
v = uint16(v);