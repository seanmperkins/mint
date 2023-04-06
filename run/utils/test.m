% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function Estimates = test(model)

% Load testing data.
[S, Z] = eval([model.Settings.task,'.get_trial_data(model.Settings,''test'')']); %#ok

% Preprocess behavioral variables.
Z = eval([model.Settings.task,'.preprocess_behavior(Z,model.Settings)']);

% Determine which spiking observations outside of the test alignment period
% will be needed to ensure to an estimate can be generated for each sample
% within the test alignment period.
test_buffer = [-model.HyperParams.window_length+1 0];
if ~model.HyperParams.causal
    test_buffer = test_buffer + round((model.HyperParams.window_length+model.HyperParams.Delta)/2);
end

% Trim spikes and behavioral variables to match the expected alignment from 
% the test set plus some buffer.
buff_align_start = model.Settings.test_alignment(1)+test_buffer(1);
buff_align_end = model.Settings.test_alignment(end)+test_buffer(2);
buffered_alignment = buff_align_start:buff_align_end;
t_mask = ismember(model.Settings.trial_alignment, buffered_alignment);
S = cellfun(@(S) S(:,t_mask), S,'un',0);
Z = cellfun(@(Z) Z(:,t_mask), Z,'un',0);

% Run MINT.
[X_hat, Z_hat] = model.predict(S);

% Remove the buffer so alignment matches desired test alignment.
not_buff_mask = ismember(buffered_alignment, model.Settings.test_alignment);
Z = cellfun(@(Z)             Z(:,not_buff_mask), Z,'un',0);
Z_hat = cellfun(@(Z_hat) Z_hat(:,not_buff_mask), Z_hat,'un',0);
X_hat = cellfun(@(X_hat) X_hat(:,not_buff_mask), X_hat,'un',0);

% Convert neural state estimates to spikes/second.
X_hat = cellfun(@(X_hat) X_hat / (model.Delta*model.Ts), X_hat,'un',0);

% Store estimates.
Estimates.Z = Z;
Estimates.Z_hat = Z_hat;
Estimates.X_hat = X_hat;