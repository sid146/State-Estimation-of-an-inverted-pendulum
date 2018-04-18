clc, clear all, close all;
%constants initialised to one.
M = 1;
m = 1;
b = 1;
I = 1;
g = 1;
l = 1;

p = I*(M+m)+M*m*l^2; %denominator for the A and B matrices

A = [0      1              0           0;
     0 -(I+m*l^2)*b/p  (m^2*g*l^2)/p   0;
     0      0              0           1;
     0 -(m*l*b)/p       m*g*l*(M+m)/p  0];
B = [     0;
     (I+m*l^2)/p;
          0;
        m*l/p];
C = [1 0 0 0;
     0 0 1 0];
D = [0;
     0];

 dt=0.1;
 tfin = 5;
 tspan = 0:dt:tfin;
 
 sysc = ss(A,B,C,D);
 sysd = c2d(sysc,dt);
 %discretisation
 Ad = sysd.A;
Bd = sysd.B;
Cd = sysd.C;
Dd = sysd.D;

%Simulation
mu = [1 0 0.1 0]';
sigma = eye(4);

u =0;
w1 = normrnd(0,0.1,100,1);
w3 = normrnd(0,0.2,100,1);
w2 = normrnd(0,0.1,100,1);
w4 = normrnd(0,0.3,100,1);
%disturbance
wn= [w1,w2,w3,w4];
%disturbance covariance matrix
Q = [0.1 0 0 0; 
    0 0.2 0 0;
    0 0 0.1 0;
    0 0 0 0.3;]; 

%gaussian noise
 %v1 = normrnd(0,.2,100,1);
 %v3 = normrnd(0,.2,100,1);
%poisson noise
 v1=poissrnd(0.1,100,1);
 v3=poissrnd(0.1,100,1);
vn= [v1,v3]; 
% R = [.2 0;
%      0 .2];
 R=cov(vn);
G=eye(4);

H = [1 0;0 1];
%linear simulations
% x(:,1) = mu;
% for i=1 :100
%      x(:,i+1) = Ad*(x(:,i))+Bd*u + (G*w(i,:)');
%      y(:,i) = Cd*x(:,i) + H*v(i,:)';
% end
% xreal(:,1) = mu;
% for i=1 :100
%     xreal(:,i+1) = Ad*(xreal(:,i))+Bd*u;
%     yreal ?,i) = Cd*(xreal(:,i));
% end

%non-linear simulations
xreal(:,1) = mu;
for i=1 :100
     t= xreal(3,i);
  x= xreal(1,i);
 v= xreal(2,i);
  w= xreal(4,i);
    xreal(:,i+1)=[v;
(4*(0+w^2*sin(t)*0.5 - 0.5*x + cos(t)*sin(t)*0.25))/(4-cos(t)^2);
w;
(4*((-0.5*sin(t)) - 0 - w^2*cos(t)*sin(t)*0.25 + x*cos(t)*0.25))/(4-cos(t)*sin(t))];
    yreal(:,i) = C*(xreal(:,i));
end
xn(:,1) = mu;

%noisy observation simulation
for i=1 :100
     xn(:,i+1) = xreal(:,i+1)+wn(i,:)';
     y(:,i) = C*xn(:,i) + H*vn(i,:)';
end
%  xreal(:,1) = mu;
% for i=1 :100
%     xreal(:,i+1) = A*(xreal(:,i))+B*u;
%     yreal ?,i) = C*(xreal(:,i));
% end

% plot(1:100,y(2,:),1:100,yreal(2,:)),legend('noisy observation','true observation'),xlabel('time'),ylabel('Angle observations')
%plot(1:100,y(1,:),1:100,yreal(1,:))


% %% kalman filter

%Q = [1 0; 0 2];  % process noise w
G = eye(4); % is the matrix associated with process noise w_k (like A)
%R = 0.1; % measurement noise v
K = [];


xest_b(:,1) =mu;
xest_c(:,1)= mu;

Pest_b(:,:,1) = sigma;
Pest_c(:,:,1) = sigma;

for n=1:100

xest_b(:,n+1) = A*xest_c(:,n)+B*u; %estimate with data before current
Pest_b(:,:,n+1) = A*Pest_c(:,:,n)*A' + Q; % estimate with data before current

K(:,:,n) = Pest_c(:,:,n)*(C'*inv(C*Pest_c(:,:,n)*C' + R));

xest_c(:,n+1) = xest_c(:,n)+(K(:,:,n)*(yreal(n)-C*xest_c(:,n)));
Pest_c(:,:,n+1) = (eye(4)- K(:,:,n)*C)*Pest_c(:,:,n);
yest(:,n) = C*xest_c(:,n);

end


 plot(1:100,yreal(1,:),1:100,yest(1,:))
   legend('true measurement','KF estimated measurement'), axis([0 100 -0.5 0.5]),xlabel('time'),ylabel('Position observations')





