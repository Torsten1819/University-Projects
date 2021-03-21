 f = 1500; % frequency of sine signal in Hz
 t = 0.001; % duration of sine signal in seconds
 
 Fs = 44100; % sampling frequency in Hz
 Ts = 1/Fs; % sampling interval in seconds
 
 t_pts = 0:Ts:t; % sampling time instants
 
 % discrete-time sine signals
 sig = sin(2*pi*f*t_pts); 
 sig2 = 0.8.*sin(2*pi*f*t_pts) + 0.5.*sin(1.5*pi*f*t_pts);
 
 
 %preallocate some space for the distance matrix and cost
 dist = zeros(length(sig), length(sig2));
 dtw_cost = zeros(length(sig), length(sig2));
 
 %get euclidean distances between each point and find dtw cost matrix
 for i = 1:length(sig)
     for j = 1: length(sig2)
         
         dist(i,j) = abs(sig2(j) - sig(i));
         
         if i> 1 && j > 1
             dtw_cost(i, j) =dist(i, j) +  min([dtw_cost(i-1, j-1),...
                 dtw_cost(i-1, j), dtw_cost(i, j-1)]);
         else
             dtw_cost(i,j) = dist(i,j);
         end
         
     end
     figure
     subplot(121);imagesc(dist);colorbar;title('Cost Matrix')
     subplot(122);imagesc(dtw_cost);colorbar;title('DTW Matrix')
 end
% 
% figure
% imagesc(dist) %our distance matrix
% colorbar
% 
% figure
% imagesc(dtw_cost) %our dynamic time warping matrix
% colorbar

figure
imagesc(dtw_cost) %our dynamic time warping matrix
colorbar


%do traceback for the path
path = [];
i = length(sig);
j = length(sig2);

path = [path; j, i];

while i>1 && j>1
%      if i==1
%          j = j - 1;
%      elseif j==1
%          i = i - 1;
%      else


        if dtw_cost(i-1, j-1) == min([dtw_cost(i-1, j-1),...
                dtw_cost(i-1, j), dtw_cost(i, j-1)])
            i = i - 1;
            j = j-1;
        elseif dtw_cost(i, j-1) == min([dtw_cost(i-1, j-1),...
                dtw_cost(i-1, j), dtw_cost(i, j-1)])
            j = j - 1;
        else
            i = i - 1;
        end
        path = [path; j, i];
        
        
%      end
    
    %lacking boundry conditions and slop constraits, sometimes causes
    %issues
end
%separate the path and plot it over the accumulated cost matrix
path_x = path(:,1)';
path_y = path(:,2)';
hold on
plot(path_x, path_y, "r", 'LineWidth',2)

%find the total cost for this path
costs = 0;

for s = 1:length(path)
    costs = costs +  dist(path_y(s), path_x(s));
end

%display out cost, compare it to the offical dtw function
[dist2, xi, yi] = dtw(sig2, sig);
plot(xi, yi, 'g')
plot(path_x, path_y, "r")
disp("My distance: " + costs)
disp("dtw() distance: " + dist2)


%plot the connection between the input signals and the dtw I found
 figure
 plot(sig, "g")
 hold on
 plot(sig2, "b")
 for q = 1:length(path_x)
     %official version
     %plot([path_x(i), path_y(i)], [sig2(path_x(i)),sig(path_y(i))], 'r') 
     
     %my version
     plot([xi(q), yi(q)], [sig2(xi(q)),sig(yi(q))], 'r')
 end
