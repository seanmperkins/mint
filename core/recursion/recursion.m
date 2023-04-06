% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function Q = recursion(Q, s_new, s_old, t_prime, L, V, first_idx, shifted_idx1, shifted_idx2, N, tau_prime)

% Time update.
Q = [0; Q(1:end-1)];
Q(first_idx) = 0;

% Measurement update.
if t_prime > tau_prime+1
    for n = 1:N
        Q = Q + L(V(:,n), s_new(n)+1);
        Q(shifted_idx2) = Q(shifted_idx2) - L(V(shifted_idx1,n), s_old(n)+1);
    end
else
    for n = 1:N
        Q = Q + L(V(:,n),s_new(n)+1);
    end
end
