% this script tests various smart charging models

%% Do the waterfilling
[Time, Cost] = water_filling_init();

% arrival / departure matrix
A = [ 
    0 0 1;
    1 0 1;
    1 1 0;
    0 1 0];
[T,N] = size(A);

% cost and load vectors
% c = [26; 25; 20; 29];
L = [12; 17; 19];

% nominal model
cvx_begin quiet
    variable Y(T,N)
    minimize( c'*diag((A*Y')) )
    subject to
        diag(A'*Y) >= L;
        Y >= 0;
cvx_end
Y = full(Y)
cost = c'*diag((A*Y'))

% robust model
rho = 11
cvx_begin quiet
    variable Y(T,N)
    minimize( c'*diag(A*Y')+rho*norm(diag(A*Y'),2))
    subject to
        diag(A'*Y) >= L;
        Y >= 0;
cvx_end
Yrob = full(Y)
costrob = c'*diag(A*Y')+rho*norm(diag(A*Y'),2)

% quadratic model
cvx_begin quiet
    variable Y(T,N)
    y = diag((A*Y'));
    minimize( norm(y,2) ) 
    subject to
        diag(A'*Y) >= L;
        Y >= 0;
cvx_end
Yq = full(Y)
costq = norm(y,2)

% scenarios
A1 = [
    0 0 1;
    1 0 1;
    1 1 0;
    0 1 0];
A2 = [
    1 0 0;
    1 0 1;
    0 1 1;
    0 1 0];
cvx_begin quiet
    variable Y(T,)
    y=diag((A*Y'));
    minimize( max(c'*diag((A1*Y')),c'*diag((A2*Y'))))
    subject to
        diag(A1'*Y) >= L;
        diag(A2'*Y) >= L;        
        Y >= 0;
cvx_end
Ys=full(Y)
