% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function alpha = fit_poisson_interp(S, X1, X2, InterpOptions, default_alpha)

% Precompute some terms that will be re-used at each iteration.
X2minusX1 = X2-X1;
X2minusX1_sum = sum(X2minusX1,'all');

% Run optimization.
alpha = 0.5;
i = 0;
while i < InterpOptions.max_iters
    
    % Compute derivatives.
    fraction = X2minusX1./(X1+alpha*X2minusX1);
    deriv1 = sum(S.*fraction,'all') - X2minusX1_sum;
    deriv2 = -sum(S.*(fraction.^2),'all');
    
    % Update alpha.
    alpha_step = deriv1/deriv2;
    alpha = alpha - alpha_step;
    
    % Check for exit conditions.
    if alpha_step < InterpOptions.step_tol || alpha < 0 || alpha > 1
        alpha = max(min(alpha,1),0);
        break
    end
    
    % Increment iteration counter.
    i = i + 1;
    
end

% If there was a problem (e.g. with dividing by zero), issue a warning and
% just return the default value provided.
if isnan(alpha)
    warning('Interpolation failed.')
    alpha = default_alpha;
end