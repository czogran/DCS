%Ten przyk³ad pokazuje jak u¿yæ klasê regulatora PID

clear all;

%classPID(K, Ti, Kd, Td, Tp, Hlim, Llim, Dir, AutoMan, ManVal) 
%DIR: 1 - direct (SP-PV), 0 - indirect (PV-SP)
% AutoMan = 0 regulator na wyjœciu podaje wartoœæ sterowania rêcznego ManVal
% AutoMan = 1 regulator na wyjœciu podaje wartoœæ wyliczon¹ z prawa regulacji
%Przyklad: deklaracja regulatora D
p=classPID(0, 0, 1, 30, 1, 100, -100, 1, 1, 0)


%PID
%reTune(obj, K, Ti, Kd, Td)
% funkcja umo¿liwia zmianê nastaw regulatora
%p.reTune(1, 30, 0.5, 30)

stpt = 1;
pv=0;
u=0;

for i=1:1:30
  %metoda wyliczaj¹ca prawo PID w oparciu o PV i STPT
  u =  p.calc(pv,stpt)
  %tutaj nale¿y symulowaæ obiekt
  %wyliczenie wyjscia obiektu na nastepny krok wykorzystujac u
  
end
