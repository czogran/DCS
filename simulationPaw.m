%Ten przyk³ad pokazuje jak u¿yæ klasê regulatora PID

% clear all;
close all


%classPID(K, Ti, Kd, Td, Tp, Hlim, Llim, Dir, AutoMan, ManVal) 
%DIR: 1 - direct (SP-PV), 0 - indirect (PV-SP)
% AutoMan = 0 regulator na wyjœciu podaje wartoœæ sterowania rêcznego ManVal
% AutoMan = 1 regulator na wyjœciu podaje wartoœæ wyliczon¹ z prawa regulacji
%Przyklad: deklaracja regulatora D
p=classPID(8, 10 ,7 , 1, 1, 1000, -10000, 1, 1, 0)
% K = 8;          % Gain
% Ti = 1;        % Integration time
% Kd = 4;         % Derivation gain
% Td = 3;         % Derivation time

%PID
%reTune(obj, K, Ti, Kd, Td)
% funkcja umo¿liwia zmianê nastaw regulatora
%p.reTune(1, 30, 0.5, 30)



stpt = 40;
pvStart=30;
startLength=400;
endLength=1000;
pvStartVector=ones(startLength,1)*pvStart;
pv=pvStart; %temp(19);
u=30;
z=0;

numerator =[0.37];
denominator =[103 1]; 
transmit = tf(numerator,denominator)
transmit.ioDelay=18;
discrete= c2d(transmit,1);

for i=1:1:startLength 
    u(i) =  p.calc(pv(i),pvStart);  
   
  pv(i+1)=0.990338239777254*pv(i)+u(i)*0.003574851282416;
end


for i=startLength+1:1:endLength
  %metoda wyliczaj¹ca prawo PID w oparciu o PV i STPT
    u(i) =  p.calc(pv(i),stpt);  

  %tutaj nale¿y symulowaæ obiekt 
  %wyliczenie wyjscia obiektu na nastepny krok wykorzystujac u 
 
   pv(i+1)=0.990338239777254*pv(i)+u(i-18)*0.003574851282416;
  
end

figure
lsim(transmit,u,1:endLength);

figure
plot(u)
hold on
% plot(pv+temp(19),'r')
plot(pv,'r')

% hold on
% toPlot=[ pvStartVector ; (step(discrete)*(stpt-pvStart)+pvStart)]
% 
% plot(toPlot,'g');
hold off
legend('u','pv')


