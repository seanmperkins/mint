% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [X_hat, Z_hat, C_hat, K_hat, Alpha_hat] = predict(obj, S)

% Get trial lengths.
T = cellfun(@(S) size(S,2), S);

% Compute number of samples in each trial for which insufficient spiking
% history will exist to generate a causal estimate.
n_early_samples = obj.Delta * (obj.tau_prime+1) - 1;

% Preallocate outputs.
n_trials = length(S);
X_hat = cell(n_trials,1);
Z_hat = cell(n_trials,1);
C_hat = cell(n_trials,1);
K_hat = cell(n_trials,1);
Alpha_hat = cell(n_trials,1);

% Bin spikes.
S_bar = cellfun(@(spikes) uint8(bin_data(spikes, obj.Delta, 'sum')), S,'un',0);

% For each trial...
for tr = 1:n_trials
    
    % Reset Q and preallocate outputs.
    Q = double(zeros(size(obj.V,1),1));
    X_hat{tr} = zeros(size(obj.Omega_plus{1},1),T(tr));
    Z_hat{tr} = zeros(size(obj.Phi_plus{1},1),T(tr));
    if obj.interp == 2
        C_hat{tr} = zeros(2,T(tr));
        K_hat{tr} = zeros(4,T(tr));
        Alpha_hat{tr} = zeros(3,T(tr));
    else
        C_hat{tr} = zeros(1,T(tr));
        K_hat{tr} = zeros(1,T(tr));
        Alpha_hat{tr} = zeros(1,T(tr));
    end
    
    % For each time bin...
    T_prime = size(S_bar{tr},2);
    for t_prime = 1:T_prime
        
        % Get spike counts.
        s_new = S_bar{tr}(:,t_prime);
        if t_prime > obj.tau_prime+1
            s_old = S_bar{tr}(:,t_prime-obj.tau_prime-1);
        else
            s_old = uint8(zeros(size(s_new)));
        end
        
        % Advance log-likelihoods recursion.
        Q = recursion_mex(Q, s_new, s_old, uint32(t_prime));
        
        % Decode neural state and behavior.
        if t_prime > obj.tau_prime
            
            % Determine the time indices that will go along with the
            % estimate for t_prime and store an associated function that
            % can similarly generate state indices from a k_prime.
            [t_idx, f] = get_time_indices(t_prime, T_prime, T(tr), obj.Delta, obj.tau_prime, obj.causal);
            
            % Estimate neural and behavioral states.
            S_curr = double(S_bar{tr}(:,t_prime-obj.tau_prime:t_prime));
            [X_hat{tr}(:,t_idx), Z_hat{tr}(:,t_idx), C_hat{tr}(:,t_idx), K_hat{tr}(:,t_idx), Alpha_hat{tr}(:,t_idx)] = estimate_states(Q, S_curr, f, obj);
            
        end
        
    end
    
    % Set minimum firing rate.
    X_hat{tr} = max(X_hat{tr}, obj.min_rate);
    
    % If estimating causally, mark any acausally generated estimates as NaNs.
    if obj.causal
        X_hat{tr}(:,1:n_early_samples) = NaN;
        Z_hat{tr}(:,1:n_early_samples) = NaN;
    end
    
    % Provide update on progress.
    disp(['Completed trial ',num2str(tr)])
    
end
