% demo of v_windows
close all;
wty=[1:5 7:15]; % list of window types to plot
for i=wty
    figure(i);
    v_windows(i,2520,'usw');
end
wty=[2,3,8,11]; % list of square root window types to plot
for i=wty
    figure(i+100);
    v_windows(i,2520,'usqw');
    title(['sqrt ' get(get(gca,'Title'),'String')]);
end
tilefigs;