% Protected by U.S. Pat. No. 11,429,847 and additional patents pending.
% © 2023 The Trustees of Columbia University in the City of New York.
% Use is subject to the terms of the License Agreement.

function generate_mex(L, V, N, tau_prime, first_idx, last_idx)

% Preallocate some useful indices (column indices for Q or V) that will be
% used to exclude either the first or last tau_prime bins of each condition.
shifted_idx1 = [];
shifted_idx2 = [];
for c = 1:length(first_idx)
    shifted_idx1 = [shifted_idx1; (first_idx(c):last_idx(c)-tau_prime-1)']; %#ok
    shifted_idx2 = [shifted_idx2; (first_idx(c)+tau_prime+1:last_idx(c))']; %#ok
end

% Create code generation configuration object.
cfg = coder.config('mex');
cfg.ConstantInputs = 'Remove';

% Declare function inputs.
inputs = cell(8,1);
inputs{1}  = coder.typeof(double(zeros(size(V,1),1))); % Q
inputs{2}  = coder.typeof(uint8(zeros(N,1)));          % s_new
inputs{3}  = coder.typeof(uint8(zeros(N,1)));          % s_old
inputs{4}  = coder.typeof(uint32(0));                  % t_prime
inputs{5}  = coder.Constant(L);                        % L
inputs{6}  = coder.Constant(V);                        % V
inputs{7}  = coder.Constant(uint32(first_idx));        % first_idx
inputs{8}  = coder.Constant(uint32(shifted_idx1));     % shifted_idx1
inputs{9}  = coder.Constant(uint32(shifted_idx2));     % shifted_idx2
inputs{10} = coder.Constant(uint32(N));                % N
inputs{11} = coder.Constant(uint32(tau_prime)); %#ok   % tau_prime

% Generate code.
cd('core/recursion')
codegen -config cfg recursion -args inputs -d recursion
rmdir recursion s
cd ../..