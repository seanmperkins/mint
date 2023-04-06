% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [X_hat, Z_hat, Lambda_tilde, beta_hat, alpha_hat_A, alpha_hat_B, c_hat_A, c_hat_B, k_idx_A, k_idx_B] = use_best_interp(S_curr, varargin)

% Find the most likely interpolation.
n_interps = nargin-1;
LL = zeros(1,n_interps);
for i = 1:n_interps
    Lambda = varargin{i}{3};
    LL(i) = sum(S_curr.*log(Lambda) - Lambda,'all'); % log-likelihood up to a constant offset
end
[~,idx] = max(LL);

% Output the variables corresponding to this interpolation.
X_hat = varargin{idx}{1};
Z_hat = varargin{idx}{2};
Lambda_tilde = varargin{idx}{3};
beta_hat = varargin{idx}{4};
alpha_hat_A = varargin{idx}{5};
alpha_hat_B = varargin{idx}{6};
c_hat_A = varargin{idx}{7};
c_hat_B = varargin{idx}{8};
k_idx_A = varargin{idx}{9};
k_idx_B = varargin{idx}{10};