% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function X_bar = smooth_average(X, HyperParams, Ts)

% Compute mean and max firing rates from an initial averaging of rates across trials.
X_avg = cellfun(@(Xc) mean(cat(3,Xc{:}),3,'omitnan'), X,'un',0);
soft_norm = HyperParams.soft_norm*HyperParams.Delta*Ts;
mu = mean(cell2mat(X_avg'),2);
norm_factor = 1 ./ (soft_norm + max(cell2mat(X_avg'),[],2));

% Mean-center and soft-normalize single trial rates.
X = cellfun(@(X) cellfun(@(X) (X - mu).*norm_factor, X,'un',0), X,'un',0);

% Use dimensionality reduction to smooth across trials within each condition.
n_conds = length(X);
if ~isnan(HyperParams.n_trial_dims)
    for c = 1:n_conds
        
        % Reshape rates into trials x neurons/times matrix.
        X_nt = cell2mat(cellfun(@(X) reshape(X',1,[]), X{c},'un',0))';
        
        % Reduce trial dimensionality with PCA.
        M = pca(X_nt,'algorithm','eig');
        M = M(:,HyperParams.n_trial_dims);
        X_nt = M*M'*X_nt';
        
        % Reshape back into cell array of matrices.
        n_trials = length(X{c});
        [N,T] = size(X{c}{1});
        X{c} = mat2cell(X_nt, ones(n_trials,1), size(X_nt,2));
        X{c} = cellfun(@(X) reshape(X,T,N)', X{c},'un',0);
        
    end
end

% Average rates across trials within each condition.
X_bar = cellfun(@(Xc) mean(cat(3,Xc{:}),3,'omitnan'), X,'un',0);

% Use dimensionality reduction to smooth across neurons.
if ~isnan(HyperParams.n_neural_dims)
    M = pca(cell2mat(X_bar')');
    M = M(:,1:HyperParams.n_neural_dims);
    X_bar = cellfun(@(X_bar) M*M'*X_bar, X_bar,'un',0);
end

% Use dimensionality reduction to smooth across conditions.
if ~isnan(HyperParams.n_cond_dims)
    [N,T] = size(X_bar{1});
    X_bar_nt = cell2mat(cellfun(@(X_bar) reshape(X_bar',1,[]), X_bar,'un',0))';
    M = pca(X_bar_nt);
    M = M(:,1:HyperParams.n_cond_dims);
    X_bar_nt = M*M'*X_bar_nt';
    X_bar = mat2cell(X_bar_nt, ones(n_conds,1), size(X_bar_nt,2));
    X_bar = cellfun(@(X_bar) reshape(X_bar,T,N)', X_bar,'un',0);
end

% Undo mean-centering and soft-normalization.
X_bar = cellfun(@(X_bar) X_bar./norm_factor + mu, X_bar,'un',0);

% Rectify reconstructed rates to ensure non-zero firing rates.
X_bar = cellfun(@(X_bar) max(X_bar,0), X_bar,'un',0);
