%% run nominal and robust optimization in different scenarios based on a binomial distribution

% Load data and generate arrival matrix A

realworlddata = readtable('real_world data.xlsx');
c = realworlddata.Price;
[T, ~] = size(c);
L = [12; 17; 19];
[N, ~] = size(L);

rng('shuffle');
rng(1);
A1 = randi([0 1], T, N);
rng(2);
A2 = randi([0 1], T, N);
rng(3)
A3 = randi([0 1], T, N);

cvx_begin quiet
    variable Y(T,N)
    minimize( max(max(c'*diag((A1*Y')),c'*diag((A2*Y'))), c'*diag((A3*Y'))))
    subject to
        diag(A1'*Y) >= L;
        diag(A2'*Y) >= L;
        diag(A3'*Y) >= L;
        Y >= 0;
cvx_end
Ys= full(Y)

rho = 100
cvx_begin quiet
    variable Y(T,N)
    minimize( max(max(c'*diag(A1*Y')+rho*norm(diag(A1*Y'),2),c'*diag(A2*Y')+rho*norm(diag(A2*Y'),2)), c'*diag(A3*Y')+rho*norm(diag(A3*Y'),2)))
    subject to
        diag(A1'*Y) >= L;
        diag(A2'*Y) >= L;
        diag(A3'*Y) >= L;
        Y >= 0;
cvx_end
Yrob = full(Y)

costs_avg = 0;
costrob_avg = 0;
A = [A1 A2 A3];
costs = zeros(3,1);
costrob = zeros(3,1);
for i = 1:3
    costs(i,1) = c'*diag((A(:,((i-1)*N+1):i*N)*Ys'));
    costs_avg = costs_avg + c'*diag((A(:,((i-1)*N+1):i*N)*Ys'));
    costrob(i,1) = c'*diag(A(:,((i-1)*N+1):i*N)*Yrob')+rho*norm(diag(A(:,((i-1)*N+1):i*N)*Yrob'),2);
    costrob_avg = costrob_avg + c'*diag(A(:,((i-1)*N+1):i*N)*Yrob')+rho*norm(diag(A(:,((i-1)*N+1):i*N)*Yrob'),2);
end
costs_avg = costs_avg / 3
costrob_avg = costrob_avg / 3
costs
costrob