%% plot worst-case objective against uncertainty level rho

A = randi([0 1], 70, 5);
[T,N] = size(A);

% cost and load vectors
c = randi([350 450], 70, 1);
L = [12; 17; 19; 21; 15];

% robust model
rho = 10:10:500;
costrob = zeros(size(rho));
for i = 1:length(rho)
    cvx_begin quiet
        variable Y(T,N)
        minimize( c'*diag(A*Y')+rho(i)*norm(diag(A*Y'),2))
        subject to
            diag(A'*Y) >= L;
            Y >= 0;
    cvx_end
    Yrob = full(Y);
    costrob(i) = c'*diag(A*Y')+rho(i)*norm(diag(A*Y'),2);
end

costrob
plot(rho,costrob,"r-o")
xlabel('rho')
ylabel('costrob')
