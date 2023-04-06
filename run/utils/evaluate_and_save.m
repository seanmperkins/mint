% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function evaluate_and_save(Settings, Estimates, TrainSummary)

% Unpack Estimates.
behavior = Estimates.Z;
behavior_estimate = Estimates.Z_hat;
neural_state_estimate = Estimates.X_hat;

% Evaluate R-squared of decoded behavior.
eval_bin_size = 5; % evaluate at 5 ms resolution (set to match Neural Latents Benchmark)
Z = cellfun(@(Z) bin_data(Z,eval_bin_size,'mean'), Estimates.Z,'un',0);
Z_hat = cellfun(@(Z_hat) bin_data(Z_hat,eval_bin_size,'mean'), Estimates.Z_hat,'un',0);
R2 = compute_R2(cell2mat(Z'), cell2mat(Z_hat'));

% Save variables as MAT file.
disp('Saving MAT file...')
if ~exist(Settings.results_path,'dir')
    mkdir(Settings.results_path);
end
filename = [Settings.results_path,Settings.task,'_decode.mat'];
save(filename, 'behavior', 'behavior_estimate', 'neural_state_estimate', 'R2', 'TrainSummary')

end

function R2 = compute_R2(Z, Z_hat)

% Remove any observations with a NaN decode. These correspond
% to times in which sufficient spiking history did not exist to
% render a decode.
nan_mask = any(isnan(Z_hat),1);
Z = Z(:,~nan_mask);
Z_hat = Z_hat(:,~nan_mask);

% Compute residual sum of squares.
SS_res = sum((Z - Z_hat).^2, 2);

% Compute total sum of squares.
SS_tot = sum((Z - mean(Z,2)).^2, 2);

% Compute coefficient of determination.
R2 = 1 - SS_res./SS_tot;

end
