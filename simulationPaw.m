close all
clc

%classPID(K, Ti, Kd, Td, Tp, Hlim, Llim, Dir, AutoMan, ManVal) 
%DIR: 1 - direct (SP-PV), 0 - indirect (PV-SP)
% AutoMan = 0 regulator na wyjœciu podaje wartoœæ sterowania rêcznego ManVal
% AutoMan = 1 regulator na wyjœciu podaje wartoœæ wyliczon¹ z prawa regulacji
%Przyklad: deklaracja regulatora D
K = 8;          % Gain
Ti = 15;        % Integration time
Kd = 4;         % Derivation gain
Td = 1;         % Derivation time

p = classPID(K, Ti ,Kd , Td, 1, 70, -30, 1, 1, 0)

%Setpoint
stpt = 10;
%Starting Process Value
pvStart=0;
%How long process is in starting value
startLength=400;
%How long is simulation of a process: startLenghth+ next steps of the
%process
endLength=1000;
%Vector for setting start process points
pvStartVector=ones(startLength,1)*pvStart;
%Process variable
pv=pvStart; 
%start control variable
u=30;

%Setting transmitation of object
numerator = 0.37;
denominator =[103 1]; 
transmit = tf(numerator,denominator);
transmit.ioDelay=18;
%Discrete transmit from 
discrete= c2d(transmit,1);

%Calculating variables for start process point
for i=1:1:startLength 
  %First controll variables
  u(i) =  p.calc(pv(i),pvStart);  
  %Process variables for start point
  %discrete.Numerator{1}(2)==0.003574851282416
  %discrete.Denominator{1}(2)==0.990338239777254
  pv(i+1)=-discrete.Denominator{1}(2)*pv(i)+u(i)*discrete.Numerator{1}(2);
end

%Calculation process variables for going to setpoint  
for i=startLength+1:1:endLength
  
  %metoda wyliczaj¹ca prawo PID w oparciu o PV i STPT
  %Method calculating PID on a base of PV and STPT
  u(i) =  p.calc(pv(i),stpt);  

  %Simulation of an object and calculating future outputs using controll
  %vaiarble
  pv(i+1)=-discrete.Denominator{1}(2)*pv(i)+u(i-18)*discrete.Numerator{1}(2);
end

%Simulation of transfer function with calculated controll variable 

% figure (1)
% lsim(transmit,u,1:endLength);

%Control variable and process variable
figure (2)
plot(u(300:800),'g')
hold on
grid on
plot(pv(300:800),'b')
plot(ones(500)*stpt,'--r')
hold off
legend('MV','PV','STPT')
xlabel("Samples")
ylabel("Amplitude")
title("PV and Controll of process"+newline...
    +"PID settings"+newline...
    +"K:"+K+"  Ti:"+Ti+"  Kd:"+Kd+"  Td:"+Td)

%saving charts
 print("PIDSimulationCharts/PIDSim_"+"K"+K+"_Ti"+Ti+"_Kd"+Kd+"_Td"+Td,'-dpng','-r500');


