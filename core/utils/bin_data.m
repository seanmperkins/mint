% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function binned_data = bin_data(data, bin_size, method)

% Calculate number of bins (truncating last bin if too few samples).
n_bins = floor(size(data,2)/bin_size);

% Bin data.
binned_data = zeros(size(data,1),n_bins);
switch method
    case 'mean'
        for n = 1:n_bins
            binned_data(:,n) = mean(double(data(:,(1:bin_size)+bin_size*(n-1))),2);
        end
    case 'sum'
        for n = 1:n_bins
            binned_data(:,n) = sum(double(data(:,(1:bin_size)+bin_size*(n-1))),2);
        end
    otherwise
        error('Unrecognized binning method.')
end