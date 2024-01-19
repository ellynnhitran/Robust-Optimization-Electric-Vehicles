realworlddata = readtable('real_world data.xlsx');
c = realworlddata.Price;
[T, ~] = size(c);
L = [12; 17; 19];
[N, ~] = size(L);

rng('shuffle');
rng(1);
A = randi([0 1], T, N);

% nominal model
cvx_begin quiet
    variable Y(T,N)
    minimize( c'*diag((A*Y')) )
    subject to
        diag(A'*Y) >= L;
        Y >= 0;
cvx_end
Yn = full(Y);

rho_vec = 10:10:100;
subtract = zeros(size(rho_vec));
% robust model
for k = 1:length(rho_vec)
    cvx_begin quiet
        variable Y(T,N)
        minimize( c'*diag(A*Y')+rho_vec(k)*norm(diag(A*Y'),2))
        subject to
            diag(A'*Y) >= L;
            Y >= 0;
    cvx_end
    Yrob = full(Y);

    % test
    n_test = 50;
    cost_nominal = zeros(n_test,1);
    cost_robust = zeros(n_test,1);
    for i = 1:n_test
        rng(i)
        c_test = randi([350 450], T, 1);
        cost_nominal(i,1) = c_test'*diag((A*Yn'));
        cost_robust(i,1) = c_test'*diag((A*Yrob'));
    end
    % cost_nominal
    % cost_robust
    nom_avg = mean(cost_nominal);
    rob_avg = mean(cost_robust);
    subtract(k) = nom_avg-rob_avg;
end

subtract
plot(rho_vec,subtract,'r--o')
xlabel('rho')
ylabel('subtract=nom_{avg}-rob_{avg}')