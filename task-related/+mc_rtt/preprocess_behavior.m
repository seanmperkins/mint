% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function [Z, beh_labels] = preprocess_behavior(Z, ~)

% Unpack finger velocity from Z. See 'Methods' section of paper for
% description of why decoding position is more complicated for this
% dataset.
Z = cellfun(@(Z) Z(3:4,:), Z,'un',0);

% Create labels to identify each behavioral variable.
beh_labels = {'xvel'; 'yvel'};