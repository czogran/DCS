% clear all;

%process w punkcie pracy (u0, y0)!!
L=0.1;
M=[1 -0.9];

K = 8;          % Gain
Ti = 10;        % Integration time
Kd = 10;         % Derivation gain
Td = 3;         % Derivation time
Tk = 1000;       % simulation time
G1p = 200;          % punkt pracy G1
T1p = 30;       % punkt pracy W1
T1zadane = 31;   % wartoœæ zadana

Tp = 1;         % Sample time
Dir = 1;        % 1 - direct (SP-PV), 0 - indirect (PV-SP)
Hlim = 1000;       % high limit
Llim = 0;       % low limit
AutoMan = 1;    % MAN when AutoMan equals to 0
ManVal = 0;     % output in MAN mode;

pid = classPID(K, Ti, Kd, Td, Tp, Hlim, Llim, Dir, AutoMan, ManVal)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step Response z dlugoscia dynamiki D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%wartosc sterowania
Upast = ones(1000,1);
%wartosci wyjsc rzeczywiste zmierzone
Ypast = ones(1000,1);

Tzad=T1zadane*ones(1000,1);

%zmienna pomocnicza
loop= 0;
%Ustawienie wartoœci przesz³ych sterowañ i wartoœci wyjœcia
Upast = Upast * G1p;
Ypast = Ypast * T1p;

Upast(1000) = G1p;
Ypast(1000) = T1p;

% Transmitancja obiektu
Gz = c2d(tf(0.35, [112, 1]), 1, 'zoh');
delay = 16;

k=1000;
while loop < k
    loop = loop+1;
    
    %y_k = f(y_k_1 + u_k_1) sumulacja procesu
    %czyli pomiar obecnej wartosci
    Y=simulateProces(Gz,Ypast(1000)-T1p,Upast(1000-delay)-G1p);
    Ypast = circshift(Ypast,-1);
    Ypast(1000) = Y+T1p;
    
    %generacja sterowania na chwile obecna k
    %w DMC liczone jest sterowanie u(k|k) 
    Upast = circshift(Upast,-1);
    Upast(1000)=G1p+pid.calc(Ypast(1000),T1zadane);

    
    %liczenie estymaty w oparciu o wzory z DMC
    %sterowanie wyliczone na chwile k nie jest uwzgledniane w predykcji
    %liczonej na chwile k
    %eY=estimateY(Ypast(1000-p), dUpast, StepResponse, p);
    %eYpast = circshift(eYpast,-1);
    %eYpast(1000) = eY;
end

subplot(2,1,1);
plot(1:1:1000,Ypast,'b',1:1:1000,Tzad,'r--');
ylabel('Temperatura T1');
xlabel('time [s]');
title('Temperatura obiektu');
subplot(2,1,2);
plot(Upast);
ylabel('Wysterowanie G1 w promilach');
xlabel('time [s]');
title('Sterowanie z PID');

function [y] = simulateProces(Gz,pastY, U)
%y = 0.9994*pastY + 0.003469*U;
y = Gz.Numerator{1}(2)*U - pastY*Gz.Denominator{1}(2);
end
