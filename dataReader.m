clc
close all

source='temp';% temp or fan
start=30;
goal =40;
switch source
    case 'fan'
        if(start==20 & goal==30)
            data= importdata('stepResponse/fan20_30_min10.txt');
        elseif (start==30 & goal ==20)
            data= importdata('stepResponse/fan30_20_min10.txt');
        elseif (start==30 & goal ==40)
            data= importdata('stepResponse/fan30_40_min10.txt');
        elseif (start==40 & goal ==30)
            data= importdata('stepResponse/fan40_30_min10.txt');  
        end
%         TODO rozszryfrowac te pliki z temperatura
    case 'temp'
         if(start==20 & goal==30)
            data= importdata('stepResponse/temp20_30_min10.txt');
        elseif (start==30 & goal ==20)
            data= importdata('stepResponse/temp30_20_min10.txt');
        elseif (start==30 & goal ==40)
%                         data= importdata('stepResponse/xd.txt');

            data= importdata('stepResponse/temp30_40_min10.txt');
        elseif (start==40 & goal ==30)
            %data= importdata('stepResponse/fan40_30_min10.txt');  
        end
end
% data= importdata('stepResponse/xd.txt');
data=data(1:2:size(data));
dataChar=char(data(2:size(data)));


k=130;
while(1)
%     temp=dataChar(:,138:2:148);
    tempChar=dataChar(:,k:2:k+10);   
    if(str2num(tempChar(1))>0)
        temp=str2num(tempChar);
        temp=flip(temp); 
       
        break;        
    end 
    k=k+1;
end


i=k+10
controlFan=0;
try
    while(1)
        controlFanChar=dataChar(:,i:2:i+10);   
        if(str2num(controlFanChar(1))>0)
            controlFan=str2num(controlFanChar);
            controlFan=flip(controlFan) ; 
            break;        
       end 
    i=i+1;
    end
end

z=i+10
controlTemp=0;
try
    while(1)
        controlTempChar=dataChar(:,z:2:z+10);   
        if(str2num(controlTempChar(1))>0)
            controlTemp=str2num(controlTempChar);  
            
            controlTemp= flip(controlTemp); 
                      

            break;        
       end 
    z=z+1;
    end
end


figure
size(controlFan,1)
try
if(size(controlFan,1)>2  & eq('fan',source) )
    plot(controlFan)
    hold on
end
end

try
if(size(controlTemp,1)>2 & eq('temp',source) )
    plot(controlTemp)
    hold on
end
end
title("y and u experimental data")
plot(temp)


%  temp=temp-mean(temp(1:100));
% controlTemp= (controlTemp)*0.01; 

%TRANSMITATION PART
% NECESSERY SYSTEM IDENTYFICATION TOOLBOX
Ts=1
data=iddata( temp,controlTemp,Ts);
% this function makes transmitation from data, params here are tricky part
trans=tfest(data,1);

numerator = trans.Numerator;
denominator = trans.Denominator;
transmitFromData= tf(numerator,denominator)

numerator =[0.37];%1.07;
denominator =[103 1]; %[400 1];
transmit = tf(numerator,denominator)
transmit.ioDelay=18;
discrete=c2d(transmit,1)
%control horizont
stero=[ones(2000,1)*0 ;ones(2000,1)*10];

figure
plot(step(discrete)*10+temp(200));
hold on
plot(temp(200:length(temp)))
title({'experimental data for temp 30-40 jump and','step response for transmit function'})
hold off

figure
lsim(transmit,stero,1:4000);
hold on
lsim(transmitFromData,stero,1:4000,'r');
 