%% evaluate nominal and scenarios model in strange data, turns out that scenarios has higher cost but satisfy better the load requirement

realworlddata = readtable('real_world data.xlsx');
c = realworlddata.Price;
[T, ~] = size(c);
L = [12; 17; 19];
[N, ~] = size(L);

rng('shuffle');
rng(7);
A1 = randi([0 1], T, N);
rng(8);
A2 = randi([0 1], T, N);
rng(3)
A3 = randi([0 1], T, N);
rng(4)
A4 = randi([0 1], T, N);
rng(5)
A5 = randi([0 1], T, N);
rng(9)
A6 = randi([0 1], T, N);
rng(10)
A7 = randi([0 1], T, N);
rng(11)
A8 = randi([0 1], T, N);
rng(12)
A9 = randi([0 1], T, N);
rng(13)
A10 = randi([0 1], T, N);

% nominal model
cvx_begin quiet
    variable Y(T,N)
    minimize( c'*diag((A1*Y')) )
    subject to
        diag(A1'*Y) >= L;
        Y >= 0;
cvx_end
Yn = full(Y);

% scenarios
cvx_begin quiet
    variable Y(T,N)
    minimize( max(max(max(c'*diag((A1*Y')),c'*diag((A2*Y'))), c'*diag((A3*Y'))), c'*diag(A4*Y')))
    subject to
        diag(A1'*Y) >= L;
        diag(A2'*Y) >= L;
        diag(A3'*Y) >= L;
        diag(A4'*Y) >= L;
        Y >= 0;
cvx_end
Ys=full(Y);

% test
cost_nom_avg = 0;
cost_scenario_avg = 0;
A = [A5 A6 A7 A8 A9 A10];
costn = zeros(6,1);
costs = zeros(6,1);
compare_load_nominal = zeros(3,6);
compare_load_scenario = zeros(3,6);
for i = 1:6
    costn(i,1) = c'*diag((A(:,((i-1)*N+1):i*N)*Yn'));
    cost_nom_avg = cost_nom_avg + c'*diag((A(:,((i-1)*N+1):i*N)*Yn'));
    compare_load_nominal(:,i) = diag((A(:,((i-1)*N+1):i*N)'*Yn)) - L;
    costs(i,1) = c'*diag((A(:,((i-1)*N+1):i*N)*Ys'));
    cost_scenario_avg = cost_scenario_avg + c'*diag((A(:,((i-1)*N+1):i*N)*Ys'));
    compare_load_scenario(:,i) = diag((A(:,((i-1)*N+1):i*N)'*Ys)) - L;
end
cost_nom_avg = cost_nom_avg / 6
cost_scenario_avg = cost_scenario_avg / 6
costn;
costs;
% the scenarios model better fulfill the load requirement but still not enough
% the more scenarios considered in training, the better fulfilling the load requirement
nom_load_fulfillment_each_scenario = mean(compare_load_nominal)
scenarios_load_fulfillment_each_scenario= mean(compare_load_scenario)
mean_nom = mean(nom_load_fulfillment_each_scenario)
mean_sc = mean(scenarios_load_fulfillment_each_scenario)