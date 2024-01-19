realworlddata = readtable('real_world data.xlsx');
c = realworlddata.Price;
[T, ~] = size(c);
L = [12; 17; 19];
[N, ~] = size(L);

n = 3; % number of scenarios
A = zeros(n*T, n*N);
for i = 1:n
    rng('shuffle');
    rng(i);
    A(((i-1)*T+1):i*T,((i-1)*N+1):i*N) = binornd(1,0.5,T,N);
end
A_disp = full(A)

% prepare load matrix
load = zeros(N*n,1);
for i = 1:n
    load((i-1)*N+1:i*N,:) = L;
end

% nominal model
cvx_begin quiet
    variable Y(n*T,n*N)
    minimize( max(c'*reshape(diag(A*Y'),T,n)))
    subject to
        diag(A'*Y) >= load;
        Y >= 0;
        Y(1:T,1:N) == Y(T+1:2*T, N+1:2*N);
        Y(T+1:2*T, N+1:2*N) == Y(2*T+1:3*T, 2*N+1:3*N);
cvx_end
Ys=full(Y)
costnom = c'*reshape(diag(A*Y'),T,n)
cost1 = c'*diag(A(1:24,1:3)*Y(1:24,1:3)')
cost2 = c'*diag(A(25:48,4:6)*Y(25:48,4:6)')

% robust model
rho=100;

cvx_begin quiet
    variable Y(n*T,n*N)
    minimize( max(c'*reshape(diag(A*Y'),T,n) + rho*[norm(A(1:T,1:N)*Y(1:T,1:N)',2),norm(A(T+1:2*T, N+1:2*N)*Y(T+1:2*T, N+1:2*N)',2),norm(A(2*T+1:3*T, 2*N+1:3*N)*Y(2*T+1:3*T, 2*N+1:3*N)',2)]))
    subject to
        diag(A'*Y) >= load;
        Y >= 0;
        Y(1:T,1:N) == Y(T+1:2*T, N+1:2*N);
        Y(T+1:2*T, N+1:2*N) == Y(2*T+1:3*T, 2*N+1:3*N);
cvx_end
Ys=full(Y)
costnom = c'*reshape(diag(A*Y'),T,n)
cost1 = c'*diag(A(1:24,1:3)*Y(1:24,1:3)')
cost2 = c'*diag(A(25:48,4:6)*Y(25:48,4:6)')


