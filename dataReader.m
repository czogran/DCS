clc
close all

%Choosing which file will be opened- source fan or heater
%Starting and ending cf process variable
source='fan';% heater or fan
start=30;
goal =20;
switch source
    case 'fan'
        if(start==20 & goal==30)
            data= importdata('stepResponse/fan20_30_min10.txt');
        elseif (start==30 & goal ==20)
            data= importdata('stepResponse/fan30_20_min10.txt');
        elseif (start==30 & goal ==40)
            data= importdata('stepResponse/fan30_40_min10.txt');
        elseif (start==40 & goal ==30)
%             missing file
%             data= importdata('stepResponse/fan40_30_min10.txt');  
        end
    case 'heater'
         if(start==20 & goal==30)
            data= importdata('stepResponse/temp20_30_min10.txt');
        elseif (start==30 & goal ==20)
            data= importdata('stepResponse/temp30_20_min10.txt');
        elseif (start==30 & goal ==40)
            data= importdata('stepResponse/temp30_40.txt');

            data= importdata('stepResponse/temp30_40_min10.txt');
        elseif (start==40 & goal ==30)
           %missing file
            %data= importdata('stepResponse/fan40_30_min10.txt');  
        end
end

% Spaces appear so every second is choosen
data=data(1:2:size(data));
dataChar=char(data(2:size(data)));

%Arbitrary Variable when we start reading data
%Getting heater Variable
k=130;
while(1)
    heaterChar=dataChar(:,k:2:k+10);   
    if(str2num(heaterChar(1))>0)
        heater=str2num(heaterChar);
        heater=flip(heater);    
        break;        
    end 
    k=k+1;
end

%Not always but sometimes after heater are Fan Controllor variable
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

%And last column in file is Control of a heater
z=i+10
controlheater=0;
try
    while(1)
        controlHeaterChar=dataChar(:,z:2:z+10);   
        if(str2num(controlHeaterChar(1))>0)
            controlHeater=str2num(controlHeaterChar);  
            controlHeater= flip(controlHeater);                     
            break;        
       end 
    z=z+1;
    end
end

%Plotting variables which were read from file
figure
plot(heater)
hold on
size(controlFan,1)
% If there is plotting of fan control
try
    if(size(controlFan,1)>2  & eq('fan',source) )
        plot(controlFan)
        hold on
    end
end

% If there is plotting of heater control
try
    if(size(controlHeater,1)>2 & eq('heater',source) )
        plot(controlHeater)
        hold on
    end
end
legend("temp",source+" controll",'Location','best')
title("y and u experimental data"+newline...
    +source+" start: "+start+" goal:"+goal);
print("StepResponseCharts/ExperimentalData_"+"source"+source+"_start"+start+"_goal"+goal,'-dpng','-r500');
hold off





%TRANSMITATION PART
if(strcmp(source,'heater'))
    %temp goeas up
    if(goal>start)
        numerator =[0.37];
        denominator =[103 1];
        transmit = tf(numerator,denominator)
        transmit.ioDelay=18;
        discrete=c2d(transmit,1)

    %temp goes down
    elseif(goal<start)
        numerator =[-0.37];
        denominator =[103 1];
        transmit = tf(numerator,denominator)
        transmit.ioDelay=5;
        discrete=c2d(transmit,1)
    end



elseif(strcmp(source,'fan'))
   if(goal>start)
        numerator =[-0.16];
        denominator =[72 1];
        transmit = tf(numerator,denominator)
        transmit.ioDelay=10;
        discrete=c2d(transmit,1)
   elseif(goal<start)
        numerator =[0.25];
        denominator =[72 1];
        transmit = tf(numerator,denominator)
        transmit.ioDelay=10;
        discrete=c2d(transmit,1)
   end
end

%moment of step: read manualy from chart
jump=215;
figure
%discrete transmit plotting
plot(step(discrete)*10+heater(jump));
hold on
%plotting experimental heater
plot(heater(jump:length(heater)))
title({"experimental data for "+ source+" "+start+"-"+goal+ " jump and","step response for transmit function"})
legend("step resopnse","experimental data",'Location','best')
hold off
print("StepResponseCharts/StepTransmit_"+"source"+source+"_start"+start+"_goal"+goal,'-dpng','-r500');

