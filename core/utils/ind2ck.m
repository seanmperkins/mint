% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [c, k] = ind2ck(i, first_idx)

% Compute c.
c = find(i >= first_idx,1,'last');

% Compute k.
k = i - first_idx(c) + 1;