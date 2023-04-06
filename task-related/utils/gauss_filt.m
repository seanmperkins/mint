% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function filt_spikes = gauss_filt(spikes, sigma, bin_size)

% Identify any samples that are NaNs.
nan_mask = any(isnan(spikes),1);
if any(nan_mask)
    
    % Check for non-consecutive NaNs.
    if ~all(diff(find(nan_mask)) == 1)
        error('Non-consecutive NaNs encountered while filtering.')
    end
    
    % Ensure block of NaNs occurred either at the beginning or end, 
    % but not in the middle of the time series.
    if ~nan_mask(1) && ~nan_mask(end)
        error('Time series broken up by a stretch of NaNs.')
    end
    
    % Remove NaN samples from spikes.
    spikes = spikes(:,~nan_mask);
    
end

% Define Gaussian kernel function.
width = 4;
N = 2*width*sigma + 1;
alpha = (N-1)/(2*sigma);
y = gausswin(N,alpha);
y = y/sum(y)*bin_size;

% Pad beginning and end of signal with values reflecting
% mean over first or last sigma values.
pre = repmat(mean(spikes(:,1:sigma),2,'double'),1,width*sigma);
post = repmat(mean(spikes(:,end-sigma+1:end),2,'double'),1,width*sigma);
input = [pre double(spikes) post];

% Convolve spikes with Gaussian kernel.
filt_spikes = zeros(size(input));
for n = 1:size(input,1)
    c = conv(input(n,:),y);
    filt_spikes(n,:) = c(width*sigma+1:end-width*sigma);
end

% Remove padding.
filt_spikes = filt_spikes(:,width*sigma+1:end-width*sigma);

% If there were NaN samples initially, add them back in.
if any(nan_mask)
    if nan_mask(1) % prepend rates
        filt_spikes = [NaN(size(filt_spikes,1),sum(nan_mask)), filt_spikes];
    else           % append rates
        filt_spikes = [filt_spikes, NaN(size(filt_spikes,1),sum(nan_mask))];
    end
end

