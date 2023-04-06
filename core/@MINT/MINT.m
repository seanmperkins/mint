% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

classdef MINT
    
    properties
        
        % Time.
        Ts              % sampling period (seconds)
        Delta           % number of samples in a time bin
        dt              % duration of time bins (seconds)
        tau_prime       % number of time bins of spike counts to use for decoding (not including current bin)
        window_length   % number of time samples of spiking activity to use for decoding (including current sample)
        causal          % logical determining whether inference should be causal or not
        
        % Trajectories.
        Omega_plus      % cell array of neural trajectories
        Phi_plus        % cell array of behavioral trajectories
        behavior_labels % cell array of labels for each behavioral variable in Phi_plus
        interp          % flag determining what type of interpolation to use
        
        % Lookup table.
        lambda_range    % vector of minimum and maximum rates to use when discretizing firing rates (spikes/bin)
        n_rates         % number of rates resulting from firing rate discretization
        rates           % vector of discretized firing rates
        max_spikes      % maximum number of allowable spikes per time bin
        min_prob        % minimum allowable likelihood of observing any particular spike count from a given neuron
        min_lambda      % minimum value of lambda used to parameterize a Poisson distribution when computing likelihoods
        L               % lookup table of log-likelihoods
        
        % Inference.
        min_rate        % smallest firing rate that will ever be inferred (spikes/bin)
        
        % Indices.
        V               % indices for querying lookup table based on neural states
        first_idx
        first_tau_prime_idx
        
        % Other
        InterpOptions
        Settings
        HyperParams
        
    end
    
    methods
        
        function obj = MINT(Settings, HyperParams)
            
            % Store settings.
            obj.Settings = Settings;
            set_list = fieldnames(Settings);
            for i = 1:length(set_list)
                set = set_list{i};
                if isprop(obj,set)
                    obj.(set) = Settings.(set);
                end
            end
            
            % Store hyperparameters.
            obj.HyperParams = HyperParams;
            hp_list = fieldnames(HyperParams);
            for i = 1:length(hp_list)
                hp = hp_list{i};
                if isprop(obj,hp)
                    obj.(hp) = HyperParams.(hp);
                end
            end
            
            % Time.
            obj.dt = obj.Delta * obj.Ts;
            obj.tau_prime = round(obj.window_length/obj.Delta) - 1;
            
            % Compute Poisson likelihoods.
            obj.n_rates = 2000;
            obj.lambda_range = [obj.min_lambda 500] * obj.dt; % spikes/bin
            obj.rates = linspace(obj.lambda_range(1),obj.lambda_range(2),obj.n_rates)';
            obj.max_spikes = round(obj.dt*1000);
            counts_mat = repmat(0:obj.max_spikes, obj.n_rates, 1);
            rates_mat = repmat(obj.rates, 1, obj.max_spikes+1);
            obj.L = poisspdf(counts_mat, rates_mat);

            % Saturate likelihoods at minimum value and ensure likelihoods
            % sum to one across all spike counts.
            obj.L(obj.L <= obj.min_prob) = NaN;
            obj.L = obj.L .* ((1 - obj.min_prob*sum(isnan(obj.L),2)) ./ sum(obj.L,2,'omitnan'));
            obj.L(isnan(obj.L)) = obj.min_prob;

            % Convert to log-likelihoods and store as lookup table.
            obj.L = log(obj.L);
            
            % Inference.
            obj.min_rate = obj.min_rate * obj.dt; % convert from spikes/sec to spikes/bin
            
            % Interpolation optimization settings.
            obj.InterpOptions.max_iters = 10;
            obj.InterpOptions.step_tol = .01;
            
        end
    end
end