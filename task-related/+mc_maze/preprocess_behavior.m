% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [Z, beh_labels] = preprocess_behavior(Z, Settings)

% Zero position at movement onset.
pos = cellfun(@(Z) Z(1:2,:) - Z(1:2,Settings.trial_alignment == 0), Z,'un',0);
Z = cellfun(@(Z,pos) [pos; Z(3:end,:)], Z, pos,'un',0);

% Create labels to identify each behavioral variable.
beh_labels = {'xpos'; 'ypos'; 'xvel'; 'yvel'};