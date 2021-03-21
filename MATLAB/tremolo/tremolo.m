% generate and play tremolo'd signal
[y2, Fs] = audioread('C:\eminor.wav');
Ts = 1/Fs; % sampling interval in seconds
y2 = y2'; %turn the data sideways
t = length(y2)/Fs; %get the length of the audio clip
%t = 2;
t_pts = 0:Ts:(t - Ts); % sampling time instants


%sig1 = sin(2*pi*440*t_pts); % test sound


%get modultion index from user
modgood = false;
m = 0;
disp('Modulation index is equal to depth knob');
while modgood == false
    m = input('Enter a modulation index between 0 and 1: ');
    if m <= 1 && m >= 0
        modgood = true;
    end
end
disp(' ');

%get speed
disp('Frequency of the LFO is equal to the speed knob');
f = input('Enter a frequency(lower is better): ');
 
disp(' ');

%get shape
shapegood = false;
while shapegood == false
    shape = input('Pick an LFO shape(1 for sine, 2 for square, 3 for triangle): ');
    if shape == 1
        sig2 = sin(2*pi*f*t_pts);%LFO sine wave
        shapegood = true;
    elseif shape == 2
        %square wave kinda sounds like shit
        sig2 = square(2*pi*f*t_pts);%LFO sq wave
        shapegood = true;
    elseif shape == 3
        sig2 = sawtooth(2*pi*f*t_pts, 0.5);%LFO saw wave
        shapegood = true;
    else
        disp('Error');
    end
end

%scaling factor 
ac = 1/(1+m);

%y= ac.*(1+m*sig2).*sig1;
y = ac.*(1+m*sig2).*y2;

hold on
plot(y2)
plot(y)
plot(sig2)
%plot(sig1)


sound(y, Fs); % play tremolo'd signal as sound

