% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [model, TrainSummary] = train(Settings, HyperParams)

% Load training data.
[S, Z, condition, Settings.CondInfo] = eval([Settings.task,'.get_trial_data(Settings,''train'')']);

% Don't optimize hyperparameters, just use those provided. But any
% hyperparameter selection method could be used here (e.g. grid search).
TrainSummary.HyperParams = HyperParams;

% Train model.
model = MINT(Settings, TrainSummary.HyperParams);
model = model.fit(S, Z, condition);

% Store behavioral variable labels.
TrainSummary.behavior_labels = model.behavior_labels;