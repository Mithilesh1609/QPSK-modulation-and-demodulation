clc;
clear all;
close all;

cnt=0;
%data=[0 1 0 1 1 1 0 1 1 1 1 1 0 1]; % information must be of even bit
data = randn(50,1);
for i=1:length(data)
    if data(i)<=0
        data(i)=0;
        %disp("data is: "+data(i));
    elseif data(i)>0
        data(i)=1;
    end
end
%Number_of_bit=1024;
%data=randint(Number_of_bit,1);
figure(1)
stem(data, 'linewidth',3), grid on;
title('  Data before Transmiting ');
xlabel("data");
ylabel("amplitude");
axis([ 0 length(data) 0 1]);
data_NRZ=2*data-1; % Data Represented at NRZ form for QPSK modulation
s_p_data=reshape(data_NRZ,2,length(data)/2);  % S/P convertion of data
br=10.^6; %Let us transmission bit rate  1000000
f=br; % minimum carrier frequency
T=1/br; % bit duration
t=T/99:T/99:T; % Time vector for one bit information

% XXXXXXXXXXXXXXXXXXXXXXX QPSK modulation  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
y=[];
y_in=[];
y_qd=[];
y_noise = [];

for i=1:length(data)/2
    y1=s_p_data(1,i)*cos(2*pi*f*t); % inphase component
    %disp("size of y1: "+size(t));
    y2=s_p_data(2,i)*sin(2*pi*f*t) ;% Quadrature component
    y_in=[y_in y1]; % inphase signal vector
    y_qd=[y_qd y2]; %quadrature signal vector
    noise = awgn(i,0,'measured');%s_p_data(1,i)*(sin(2*pi*f*t)+randn(1,99));%((sqrt(0.1)*(randn(1,99)+randn(1,99)))); %noise component
    %disp("size of noise is: "+size(noise));
    y_noise = [y_noise noise]; % noise vector
    y=[y y1+y2+noise]; % modulated signal vector
    %disp(y);
end

disp("size of the noise"+size(y_noise));
Tx_sig=y; % transmitting signal after modulation
tt=T/99:T/99:(T*length(data))/2;
figure(2)
disp("size of tt: "+size(tt));

subplot(4,1,1);
plot(tt,y_in,'linewidth',3), grid on;
title(' wave form for inphase component in QPSK modulation ');
xlabel('time(sec)');
ylabel(' amplitude(volt0)');

subplot(4,1,2);
plot(tt,y_qd,'linewidth',3), grid on;
title(' wave form for Quadrature component in QPSK modulation ');
xlabel('time(sec)');
ylabel(' amplitude(volt0');

subplot(4,1,3);
plot(y_noise,'linewidth',3), grid on;
title(' wave form for noise component in QPSK modulation ');
xlabel('time(sec)');
ylabel(' amplitude(volt0');

subplot(4,1,4);
plot(tt,Tx_sig,'r','linewidth',3), grid on;
title('QPSK modulated signal (sum of inphase and Quadrature phase signal and noise)');
xlabel('time(sec)');
ylabel(' amplitude(volt0');

% XXXXXXXXXXXXXXXXXXXXXXXXXXXX QPSK demodulation XXXXXXXXXXXXXXXXXXXXXXXXXX

Rx_data=[];
Rx_sig=Tx_sig; % Received signal
rx_qd_data=[];
for(i=1:1:length(data)/2)
    %%XXXXXX inphase coherent dector XXXXXXX
    Z_in=Rx_sig((i-1)*length(t)+1:i*length(t)).*cos(2*pi*f*t); 
    % above line indicats multiplication of received & inphase carred signal
    
    Z_in_intg=(trapz(t,Z_in))*(2/T);% integration using trapizodial rule
    if(Z_in_intg>0) % Decession Maker
        Rx_in_data=1;
    else
       Rx_in_data=0; 
    end
    
    %%XXXXXX Quadrature coherent dector XXXXXX
    Z_qd=Rx_sig((i-1)*length(t)+1:i*length(t)).*sin(2*pi*f*t);
    %above line indicat multiplication of received & Quadphase carred signal
    
    Z_qd_intg=(trapz(t,Z_qd))*(2/T);%integration using trapizodial rule
        if (Z_qd_intg>0)% Decession Maker
             Rx_qd_data=1;
        else
            Rx_qd_data=0; 
        end
                
    Rx_data=[Rx_data  Rx_in_data  Rx_qd_data]; % Received Data vector
    rx_qd_data = [rx_qd_data Rx_qd_data];
    
    
end
 disp(Rx_data);
   
disp(length(Rx_data));
for i=1:length(Rx_data)
   if(data(i)~=Rx_data(i))
        cnt = cnt+1;
    end
    disp("data is: "+data(i));
    disp("Receivered data is: "+Rx_data(i));
end%%
figure(3)
stem(Rx_data,'linewidth',2) 
title('Information after Receiveing ');
axis([ 0 length(data) 0 1]), grid on;

disp("cnt is: "+cnt);
disp("len of rx: "+length(Rx_data));
bit_error_probability = (cnt/length(Rx_data));
disp("bit error probabilty is:  "+bit_error_probability);
cnt=0;