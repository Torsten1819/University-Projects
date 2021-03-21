function selectchat
global usrname;
global usrpswd;
global adrs;
global state;
global chatname;
global workingdir;
global cftp;


%% initialize figure and uicontrols
hSelect = figure('Units','Pixels',...
                'Position', [500 200 350 300],...
                'MenuBar','none',...
                'ToolBar','none',...
                'Resize', 'off',...
                'CloseRequestFcn',@closereq,...
                'Name', 'Select Chatroom');
p = uipanel(hSelect,'Position',[.02 .02 .96 .96]);

joinPB = uicontrol(p,'Style','pushbutton',...
                'String','Join',...
                'Units','normalized',...
                'FontSize',10,...
                'Callback',@joinPB_callback,...
                'Position',[.075 .05 .25 .1]);
      
createPB = uicontrol(p,'Style','pushbutton',...
                'String','Create',...
                'Units','normalized',...
                'FontSize',10,...
                'Callback',@createPB_callback,...
                'Position',[.375 .05 .25 .1]);
            
quitPB = uicontrol(p,'Style','pushbutton',...
                'String','Quit',...
                'Units','normalized',...
                'FontSize',10,...
                'Callback',@quitPB_callback,...
                'Position',[.675 .05 .25 .1]);
            
titleST = uicontrol(p,'Style','text',...
                'String','Select a Chatroom',...
                'FontSize',12,...
                'Units','normalized',...
                'Position',[.25 .85 .5 .1]);
            
lb = uicontrol(p,'Style','listbox',...
                'tag', 'lb',...
                'String',{''},...
                'FontSize',10,...
                'Units','normalized',...
                'KeyPressfcn',{@KeyPress_Function,hSelect},...
                'Position',[.1 .2 .8 .65],...
                'Value',1);
%% end control initialization
%timer to check for new chatrooms, executes every 15 seconds
updater = timer('ExecutionMode', 'fixedRate', 'Period', 15, 'TimerFcn', @updateTimer);
findchatrooms;%function to find new chat rooms
start(updater);

uiwait(hSelect);%pause the state machine

    %timer function calls the findchatroom function
    function updateTimer(src, event)
        findchatrooms;
    end
   
  %searches the server for "chatrooms"
  function findchatrooms
     lbhandle = findobj( 'tag', 'lb');
     
     details = dir(cftp);%%gets a structure containing the directory information of the server
     try %%tries to turn the structure into cells so that they can be more easily scanned
        s = struct2cell(details);
        sizing = size(s);
        validsize = 0;
        for a = 1:sizing(2)
            if s{3,a} == 1
                validsize = validsize +1;
            end
        end
        list = cell(1, validsize);
        i = 1;
        for b = 1:sizing(2)
            if s{3,b} == 1
                list(1,i) = cellstr(s{1,b});
                i = i+1;
            end
        end
        set(lbhandle, 'String', list);
     catch %%if this was not possible, it means there are no files on the server
         msgbox('No chatrooms found, please create one.');
     end

  end

%attempted to close the entire program
function quitPB_callback (src, event)
    closereq;
end

%"joins" the chatroom
function joinPB_callback (src, event)
    state = 3; %%goes to state 3 aka cipher
    lbhandle = findobj( 'tag', 'lb');
    listindex = get(lbhandle, 'Value');
    listvalues = get(lbhandle, 'String');
    chatname = listvalues{listindex}; %%checks what chatroom was selected in the list box
    fig = ancestor(src, 'figure');
    
    cd('chatlog'); %goes to the local chatlog folder
    if exist(chatname, 'file') ~= 7%if it does't exist, it makes the local chatroom and creates the required files for it to run correctly
        mkdir(chatname);
        cd(chatname);
        dlmwrite('Shared.csv', 50);
        dlmwrite('history.csv', []);
    end
    cd(workingdir);
    uiresume(fig); %continues the state machine
    closereq(src);%closes the gui with next state as state 3
end
function createPB_callback (src, event)
        %%% will create a new folder and chat file on server
        newname = inputdlg('Enter the name of the new chatroom');
        try %tries to create a new chatroom using the filename entered in the input dialog
            filename = newname{1};
        catch
            %%%user pressed cancel
            return;
        end;
            
        
        %%%makes required directories and files on the server to act as the
        %%%stub for the chatroom
        mkdir(cftp,filename);
        dlmwrite([filename '.csv'], []);
        cd(cftp, filename);
        mput(cftp, [filename '.csv']);
        dlmwrite('Shared.csv', 50);
        dlmwrite('history.csv', []);
        mput(cftp, 'Shared.csv');
        mput(cftp, 'history.csv')
        cd(cftp, '..');
        delete('Shared.csv');
        delete('history.csv');
        delete([filename '.csv']);
        findchatrooms;    %%loads your new chatroom back into the list box   
end

function closereq(hObject, eventdata, handles)
    if nargin == 1
        %%don't change the next state
    else
        state = 5; %%goes to state 5 aka close
    end
    try
        stop(updater);%%%you really need to try and stop the timer
    catch
    end
    delete(gcf);
end
%%%if the user presses enter while selecting a chatroom, it will act as if
%%%the join button was pressed
function KeyPress_Function(h,eventdata,fig)

    drawnow;
    key = get(fig,'currentkey');
    drawnow
    switch key
        case 'return'
            joinPB_callback(h, eventdata);
            drawnow;
            return;
    end

end

end
            