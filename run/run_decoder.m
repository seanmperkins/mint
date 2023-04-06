% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

% Clear variables, move to the appropriate directory, and update the path.
clearvars
filepath = mfilename('fullpath');
cd(filepath(1:strfind(filepath,'/run/')))
addpath(genpath('core'))
addpath(genpath('task-related'))
addpath(genpath('run'))

% Pick the dataset you wish to run.
dataset = 'area2_bump'; % 'area2_bump', 'mc_maze', 'mc_rtt'

% Get settings for this dataset.
[Settings, HyperParams] = config.(dataset);

% Train model.
[model, TrainSummary] = train(Settings, HyperParams);

% Make predictions.
Estimates = test(model);

% Evaluate and save results.
evaluate_and_save(Settings, Estimates, TrainSummary);

