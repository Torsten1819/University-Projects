inputs = [ 1 0 0 0 0 0 0 0; 0 1 0 0 0 0 0 0; ...
    0 0 1 0 0 0 0 0; 0 0 0 1 0 0 0 0; ...
    0 0 0 0 1 0 0 0; 0 0 0 0 0 1 0 0; ...
    0 0 0 0 0 0 1 0; 0 0 0 0 0 0 0 1]';

output = [0 0 0 0 0 0 0 0]';
hidden = [0 0 0]';
alpha = 0.3;%learning rate
W1 = 2*rand(3,8)-1;
W2 = 2*rand(8,3)-1;
NW1 = zeros(3,8);
NW2 = zeros(8,3);

epochs = 100;
epochs2 = 250;

%shit for plotting
costplot= [];
plotweight1 = [];
plotweight2 = [];
plothid1 = [];
plothid2 = [];
plothid3 = [];
plothid4 = [];
plothid5 = [];
plothid6 = [];
plothid7 = [];
plothid8 = [];

for i = 1:epochs
   for seed = 1:8
       for j = 1:epochs2
           %get out input for this time
           curin = inputs(:,seed);
           curout = curin;
           
           %calculate hidden values
           hidden = W1*curin;
           
           %activate hidden values
           hidden = 1./(1 + exp(-hidden));
           
           %calculate the output layer
           output = W2*hidden;
           
           %activate
           output = 1./(1+exp(-output));
           
           %calc error
           Ct = sum((curout - output).^2)./2;
           
           %backprop
           del = (output - curout).*(1 - output).*output;
           
           NW2(1,:) = W2(1,:) - alpha.*del(1).*hidden';
           NW2(2,:) = W2(2,:) - alpha.*del(2).*hidden';
           NW2(3,:) = W2(3,:) - alpha.*del(3).*hidden';
           NW2(4,:) = W2(4,:) - alpha.*del(4).*hidden';
           NW2(5,:) = W2(5,:) - alpha.*del(5).*hidden';
           NW2(6,:) = W2(6,:) - alpha.*del(6).*hidden';
           NW2(7,:) = W2(7,:) - alpha.*del(7).*hidden';
           NW2(8,:) = W2(8,:) - alpha.*del(8).*hidden';
           
           %backprop for input to hidden layer weights
           summer = [dot(del,W2(:,1))  dot(del,W2(:,2))  dot(del,W2(:,3))]';
           deltest = hidden.*(1 - hidden).*summer;
           
           NW1(1,:) = W1(1,:) - alpha.*deltest(1).*curin';
           NW1(2,:) = W1(2,:) - alpha.*deltest(2).*curin';
           NW1(3,:) = W1(3,:) - alpha.*deltest(3).*curin';
           
           %update the weight matricies
           W1 = NW1;
           W2 = NW2;
       end
       
   end
   i
   tempcost = 0;
   tempout = 0;
   plotweight1 = [plotweight1 W1];
   plotweight2 = [plotweight2 W2];
   
   hidden = 1./(1 + exp(-(W1*inputs(:,1))));
   plothid1 = [plothid1 hidden];
   tempout = 1./(1+exp(-(W2*hidden)));
   tempcost = tempcost + sum((inputs(:,1) - tempout).^2)./2;
   
   hidden = 1./(1 + exp(-(W1*inputs(:,2))));
   plothid2 = [plothid2 hidden];
   tempout = 1./(1+exp(-(W2*hidden)));
   tempcost = tempcost + sum((inputs(:,2) - tempout).^2)./2;
   
   hidden = 1./(1 + exp(-(W1*inputs(:,3))));
   plothid3 = [plothid3 hidden];
   tempout = 1./(1+exp(-(W2*hidden)));
   tempcost = tempcost + sum((inputs(:,3) - tempout).^2)./2;
   
   hidden = 1./(1 + exp(-(W1*inputs(:,4))));
   plothid4 = [plothid4 hidden];
   tempout = 1./(1+exp(-(W2*hidden)));
   tempcost = tempcost + sum((inputs(:,4) - tempout).^2)./2;
   
   hidden = 1./(1 + exp(-(W1*inputs(:,5))));
   plothid5 = [plothid5 hidden];
   tempout = 1./(1+exp(-(W2*hidden)));
   tempcost = tempcost + sum((inputs(:,5) - tempout).^2)./2;
   
   hidden = 1./(1 + exp(-(W1*inputs(:,6))));
   plothid6 = [plothid6 hidden];
   tempout = 1./(1+exp(-(W2*hidden)));
   tempcost = tempcost + sum((inputs(:,6) - tempout).^2)./2;
   
   hidden = 1./(1 + exp(-(W1*inputs(:,7))));
   plothid7 = [plothid7 hidden];
   tempout = 1./(1+exp(-(W2*hidden)));
   tempcost = tempcost + sum((inputs(:,7) - tempout).^2)./2;
   
   hidden = 1./(1 + exp(-(W1*inputs(:,8))));
   plothid8 = [plothid8 hidden];
   tempout = 1./(1+exp(-(W2*hidden)));
   tempcost = tempcost + sum((inputs(:,8) - tempout).^2)./2;
   
   tempcost = tempcost/8;
   costplot = [costplot tempcost];
    
end

%plot(costplot2)
%verification
verif = [];
%verhid = [];
for q = 1:8
    intest = inputs(:,q);
    hidden = W1*intest;
    hidden = 1./(1 + exp(-hidden));
    %verhid = [verhid hidden];
    %calculate the output layer
    output = W2*hidden;
    %activate
    output = 1./(1+exp(-output));
    verif = [ verif intest output];
end
disp(verif(:,1:8))
disp(verif(:,9:16))
%disp(verhid)

%LET'S PLOT ALL OF THE THINGS!!!!
figure
plot(plothid1(1,:))
title('Hidden Values for Input 1')
hold on
plot(plothid1(2,:))
plot(plothid1(3,:))

figure
plot(plothid2(1,:))
title('Hidden Values for Input 2')
hold on
plot(plothid2(2,:))
plot(plothid2(3,:))

figure
plot(plothid3(1,:))
title('Hidden Values for Input 3')
hold on
plot(plothid3(2,:))
plot(plothid3(3,:))

figure
plot(plothid4(1,:))
title('Hidden Values for Input 4')
hold on
plot(plothid4(2,:))
plot(plothid4(3,:))

figure
plot(plothid5(1,:))
title('Hidden Values for Input 5')
hold on
plot(plothid5(2,:))
plot(plothid5(3,:))

figure
plot(plothid6(1,:))
title('Hidden Values for Input 6')
hold on
plot(plothid6(2,:))
plot(plothid6(3,:))

figure
plot(plothid7(1,:))
title('Hidden Values for Input 7')
hold on
plot(plothid7(2,:))
plot(plothid7(3,:))

figure
plot(plothid8(1,:))
title('Hidden Values for Input 8')
hold on
plot(plothid8(2,:))
plot(plothid8(3,:))

figure
plot(costplot)
title('Average Cost per Training Epoch')

figure
plot(plotweight1(1,1:8:end))
title('Weights to Hidden Neuron 1');
hold on
plot(plotweight1(1,2:8:end))
plot(plotweight1(1,3:8:end))
plot(plotweight1(1,4:8:end))
plot(plotweight1(1,5:8:end))
plot(plotweight1(1,6:8:end))
plot(plotweight1(1,7:8:end))
plot(plotweight1(1,8:8:end))

figure
plot(plotweight1(2,1:8:end))
title('Weights to Hidden Neuron 2');
hold on
plot(plotweight1(2,2:8:end))
plot(plotweight1(2,3:8:end))
plot(plotweight1(2,4:8:end))
plot(plotweight1(2,5:8:end))
plot(plotweight1(2,6:8:end))
plot(plotweight1(2,7:8:end))
plot(plotweight1(2,8:8:end))

figure
plot(plotweight1(3,1:8:end))
title('Weights to Hidden Neuron 3');
hold on
plot(plotweight1(3,2:8:end))
plot(plotweight1(3,3:8:end))
plot(plotweight1(3,4:8:end))
plot(plotweight1(3,5:8:end))
plot(plotweight1(3,6:8:end))
plot(plotweight1(3,7:8:end))
plot(plotweight1(3,8:8:end))

figure
plot(plotweight2(1,1:3:end))
title('Weights to Output Neuron 1')
hold on
plot(plotweight2(1,2:3:end))
plot(plotweight2(1,3:3:end))

figure
plot(plotweight2(2,1:3:end))
title('Weights to Output Neuron 2')
hold on
plot(plotweight2(2,2:3:end))
plot(plotweight2(2,3:3:end))

figure
plot(plotweight2(3,1:3:end))
title('Weights to Output Neuron 3')
hold on
plot(plotweight2(3,2:3:end))
plot(plotweight2(3,3:3:end))

figure
plot(plotweight2(4,1:3:end))
title('Weights to Output Neuron 4')
hold on
plot(plotweight2(4,2:3:end))
plot(plotweight2(4,3:3:end))

figure
plot(plotweight2(5,1:3:end))
title('Weights to Output Neuron 5')
hold on
plot(plotweight2(5,2:3:end))
plot(plotweight2(5,3:3:end))

figure
plot(plotweight2(6,1:3:end))
title('Weights to Output Neuron 6')
hold on
plot(plotweight2(6,2:3:end))
plot(plotweight2(6,3:3:end))

figure
plot(plotweight2(7,1:3:end))
title('Weights to Output Neuron 7')
hold on
plot(plotweight2(7,2:3:end))
plot(plotweight2(7,3:3:end))

figure
plot(plotweight2(8,1:3:end))
title('Weights to Output Neuron 8')
hold on
plot(plotweight2(8,2:3:end))
plot(plotweight2(8,3:3:end))
