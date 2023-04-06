% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [c_hat, k_prime_hats] = maximum_likelihood(Q, tau_prime, first_idx, first_tau_prime_idx, varargin)

% Get trajectory lengths.
K = [first_idx(2:end); length(Q)+1] - first_idx;

% Implement any restrictions regarding which states in Q should be selected.
Q(first_tau_prime_idx) = NaN;
if length(varargin) == 1 % restriction on conditions
    restricted_conds = varargin{1};
    if ~isempty(restricted_conds)
        for i = 1:length(restricted_conds)
            c = restricted_conds(i);
            Q(ck2ind(c,1:K(c),first_idx)) = NaN;
        end
    end
elseif length(varargin) == 2 % restriction on states close to other candidate states
    states_to_exclude = varargin{1};
    min_k_prime_dist = varargin{2};
    if ~isempty(states_to_exclude)
        for i = 1:length(states_to_exclude)
            c_exclude = states_to_exclude{i}(1);
            k_prime_exclude = states_to_exclude{i}(2);
            relevant_indices = ck2ind(c_exclude,[1,k_prime_exclude,K(c_exclude)],first_idx);
            exclude_start = max(relevant_indices(2)-min_k_prime_dist, relevant_indices(1));
            exclude_end   = min(relevant_indices(2)+min_k_prime_dist, relevant_indices(3));
            Q(exclude_start:exclude_end) = NaN;
        end
    end
end

% Select neural state that maximizes Q.
[~,idx] = max(Q);
[c_hat, k1] = ind2ck(idx, first_idx);

% Determine which adjacent neural state to interpolate to. If both are
% options, choose the more likely state.
Q_c = Q(ck2ind(c_hat,1:K(c_hat),first_idx));
if k1 > tau_prime+1 && k1 < K(c_hat)
    if Q_c(k1-1) > Q_c(k1+1)
        k2 = k1-1;
    else
        k2 = k1+1;
    end
elseif k1 > tau_prime+1
    k2 = k1-1;
else
    k2 = k1+1;
end

% Store the two state indices together.
k_prime_hats = [k1 k2];


