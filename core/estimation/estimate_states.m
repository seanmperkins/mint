% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [X_hat, Z_hat, C_hat, K_hat, Alpha_hat] = estimate_states(Q, S_curr, f, obj)

% Get trajectory lengths.
K = cellfun(@(Phi_plus) size(Phi_plus,2), obj.Phi_plus);

% Proceed depending on interpolation flag.
switch obj.interp
    
    case 0
        
        % Estimate the most likely pair of adjacent states.
        conds_to_exclude = [];
        [c_hat, ~, k_idx] = select_likely_states(conds_to_exclude);
        
        % Don't interpolate - just choose the most likely of the two.
        X_hat = obj.Omega_plus{c_hat}(:,k_idx(1,:));
        Z_hat = obj.Phi_plus{c_hat}(:,k_idx(1,:));
        
        % Store estimated state condition-index values.
        C_hat = c_hat*ones(1,size(Z_hat,2));
        K_hat = k_idx(1,:);
        Alpha_hat = NaN(1,size(Z_hat,2));
        
    case 1
        
        % Estimate the most likely pair of adjacent states.
        conds_to_exclude = [];
        [c_hat, k_prime_hats, k_idx] = select_likely_states(conds_to_exclude);
        
        % Interpolate across adjacent indices.
        [X_hat, Z_hat, ~, alpha_hat] = interp_adjacent_states(c_hat, k_prime_hats, k_idx);
        
        % Don't store estimated state condition-index values.
        C_hat = NaN(1,size(Z_hat,2));
        K_hat = NaN(1,size(Z_hat,2));
        Alpha_hat = alpha_hat*ones(1,size(Z_hat,2));
        
    case 2
        
        % Unpack relevant hyperparameters.
        n_candidates = obj.HyperParams.n_candidates;
        interp_within_trajectories = obj.HyperParams.interp_within_trajectories;
        min_k_dist = obj.HyperParams.min_k_dist;
        min_k_prime_dist = min_k_dist/obj.Delta;

        % Preallocate/initialize variables.
        Candidates = cell(n_candidates,1);
        if interp_within_trajectories
            states_to_exclude = {};
        else
            conds_to_exclude = [];
        end

        % Select candidate states (and interpolate across adjacent indices).
        for i = 1:n_candidates

            % Get candidate conditions (c) and indices (k).
            if interp_within_trajectories
                [c_hat_i, k_prime_hats_i, k_idx_i] = select_likely_states(states_to_exclude, min_k_prime_dist);
                states_to_exclude = cat(1,states_to_exclude,{[c_hat_i, k_prime_hats_i(1)]}); % exclude nearby states from subsequent candidate state selection
            else
                [c_hat_i, k_prime_hats_i, k_idx_i] = select_likely_states(conds_to_exclude);
                conds_to_exclude = [conds_to_exclude, c_hat_i]; %#ok, exclude condition from subsequent state selection
            end
            
            % Interpolate across adjacent indices.
            [X_hat_i, Z_hat_i, Lambda_tilde_i, alpha_hat_i] = interp_adjacent_states(c_hat_i, k_prime_hats_i, k_idx_i);

            % Store candidate state info.
            Candidates{i} = {X_hat_i, Z_hat_i, Lambda_tilde_i, alpha_hat_i, c_hat_i, k_idx_i};

        end
        
        % Create a list of all candidate state pairs.
        state_pairs = nchoosek(1:n_candidates,2);

        % Interpolate between all state pairs.
        n_pairs = size(state_pairs,1);
        Interps = cell(n_pairs,1);
        for i = 1:n_pairs

            % Get the two states for this pair.
            s_A = state_pairs(i,1);
            s_B = state_pairs(i,2);
            
            % Unpack relevant candidate state info.
            X_hat_A        = Candidates{s_A}{1};
            X_hat_B        = Candidates{s_B}{1};
            Z_hat_A        = Candidates{s_A}{2};
            Z_hat_B        = Candidates{s_B}{2};
            Lambda_tilde_A = Candidates{s_A}{3};
            Lambda_tilde_B = Candidates{s_B}{3};
            alpha_hat_A    = Candidates{s_A}{4};
            alpha_hat_B    = Candidates{s_B}{4};
            c_hat_A        = Candidates{s_A}{5};
            c_hat_B        = Candidates{s_B}{5};
            k_idx_A        = Candidates{s_A}{6};
            k_idx_B        = Candidates{s_B}{6};

            % Interpolate.
            [X_hat_AB, Z_hat_AB, Lambda_tilde_AB, beta_hat_AB] = interp_states(Lambda_tilde_A, Lambda_tilde_B, X_hat_A, X_hat_B, Z_hat_A, Z_hat_B);

            % Store interpolation info.
            Interps{i} = {X_hat_AB, Z_hat_AB, Lambda_tilde_AB, beta_hat_AB, alpha_hat_A, alpha_hat_B, c_hat_A, c_hat_B, k_idx_A, k_idx_B};

        end

        % Choose best interpolation.
        [X_hat, Z_hat, ~, beta_hat, alpha_hat_A, alpha_hat_B, c_hat_A, c_hat_B, k_idx_A, k_idx_B] = use_best_interp(S_curr, Interps{:});

        % Store estimated state condition-index values.
        C_hat = [c_hat_A; c_hat_B].*ones(1,size(Z_hat,2));
        K_hat = [k_idx_A; k_idx_B];
        Alpha_hat = [beta_hat; alpha_hat_A; alpha_hat_B].*ones(1,size(Z_hat,2));
        
end

    function [c_hat, k_prime_hats, k_idx] = select_likely_states(varargin)
        
        % Get the maximum likelihood neural state along with the most
        % likely adjacent state, excluding states that either lack
        % sufficient history or have been explicitly excluded.
        [c_hat, k_prime_hats] = maximum_likelihood(Q, obj.tau_prime, obj.first_idx, obj.first_tau_prime_idx, varargin{:});
        
        % Convert k_prime_hats to k_idx in a manner that matches how 
        % t_prime was converted to t_idx.
        k_idx = get_state_indices(k_prime_hats, f, K(c_hat));
        
    end

    function [X_hat, Z_hat, Lambda_tilde, alpha_hat] = interp_adjacent_states(c_hat, k_prime_hats, k_idx)
        
        % Construct lambdas.
        idx1 = ck2ind(c_hat, k_prime_hats(1) + (-obj.tau_prime:0), obj.first_idx);
        idx2 = ck2ind(c_hat, k_prime_hats(2) + (-obj.tau_prime:0), obj.first_idx);
        Lambda1 = obj.rates(obj.V(idx1,:))';
        Lambda2 = obj.rates(obj.V(idx2,:))';
        
        % Learn interpolation parameter.
        alpha_hat = fit_poisson_interp(S_curr, Lambda1, Lambda2, obj.InterpOptions, 0);
        
        % Apply interpolation.
        Lambda_tilde = (1-alpha_hat)*Lambda1 + alpha_hat*Lambda2;
        X_hat = (1-alpha_hat)*obj.Omega_plus{c_hat}(:,k_idx(1,:)) + alpha_hat*obj.Omega_plus{c_hat}(:,k_idx(2,:));
        Z_hat = (1-alpha_hat)*obj.Phi_plus{c_hat}(:,k_idx(1,:))   + alpha_hat*obj.Phi_plus{c_hat}(:,k_idx(2,:));
        
    end

    function [X_hat, Z_hat, Lambda_tilde, beta_hat] = interp_states(Lambda1, Lambda2, X_hat1, X_hat2, Z_hat1, Z_hat2)
        
        % Learn interpolation parameter.
        beta_hat = fit_poisson_interp(S_curr, Lambda1, Lambda2, obj.InterpOptions, 0);
        
        % Apply interpolation.
        Lambda_tilde = (1-beta_hat)*Lambda1 + beta_hat*Lambda2;
        X_hat = (1-beta_hat)*X_hat1 + beta_hat*X_hat2;
        Z_hat = (1-beta_hat)*Z_hat1 + beta_hat*Z_hat2;
        
    end

end