function chatroom
global usrname;
global adrs;
global usrpswd;
global state;
global chatname;
global cipher;
global serverchat;
global dispchat;
global workingdir;
global otherdir;
global isotherupload;

hChatroom = figure('Units','Pixels',...
                'Position', [500 200 400 500],...
                'MenuBar','none',...
                'ToolBar','none',...
                'Resize', 'off',...
                'CloseRequestFcn',@closereq,...
                'Name', chatname);
            
p = uipanel(hChatroom,'Position',[.02 .02 .96 .96]);

sendmPB = uicontrol(p,'Style','pushbutton',...
                    'String','Send Msg',...
                    'FontSize',10,...
                    'Units','normalized',...
                    'Callback',@sendmPB_callback,...
                    'Position',[.7 .05 .25 .1]);
selectPB = uicontrol(p,'Style','pushbutton',...
                    'String','Switch Rooms',...
                    'FontSize',10,...
                    'Units','normalized',...
                    'Callback',@selectPB_callback,...
                    'Position', [.05 .11 .25 .07]);
                
sendfPB = uicontrol(p,'Style','pushbutton',...
                    'String','Send File',...
                    'FontSize',10,...
                    'Units','normalized',...
                    'Callback',@sendfPB_callback,...
                    'Position',[.375 .11 .25 .07]);
historyPB = uicontrol(p,'Style','pushbutton',...
                    'String','Chat History',...
                    'FontSize',10,...
                    'Units','normalized',...
                    'Callback',@historyPB_callback,...
                    'Position',[.375 .02 .25 .07]);
                
quitPB = uicontrol(p,'Style','pushbutton',...
                    'String','Quit',...
                    'Units','normalized',...
                    'FontSize',10,...
                    'Callback',@quitPB_callback,...
                    'Position',[.05 .02 .25 .07]);

               

chatboxTB = uicontrol(p,'Style','edit',...
                    'String','',...
                    'tag', 'chatTB',...
                    'FontSize',10,...
                    'HorizontalAlignment','left',...
                    'Max', 2,...
                    'Units','normalized',...
                    'Position',[.025 .3 .95 .675]);
jEdit=findjobj(chatboxTB,'nomenu'); %get the UIScrollPane container
set(jEdit,'VerticalScrollBarPolicy',javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED);
jEdit.anchorToBottom;
jEdit=jEdit.getComponent(0).getComponent(0);
set(jEdit,'Editable',0);
%%% this forced the scroll bar to focus to the bottom instead of the top



msgboxTB = uicontrol(p,'Style','edit',...
                    'String','Type your message here',...
                    'tag', 'msgTB',...
                    'FontSize',10,...
                    'HorizontalAlignment','right',...
                    'KeyPressfcn',{@KeyPress_Function,hChatroom},...
                    'Units','normalized',...
                    'Position',[.025 .2 .95 .08]);

cftp = ftp(adrs, usrname,usrpswd);%log into server
cd(cftp, chatname);%change to the chatroom on the server
%create timers to check if there are files to download or to avoid
%overlapping uploads
polling = timer('ExecutionMode', 'fixedRate', 'Period', 1, 'TimerFcn', @pollingTimer);
uptimer = timer('ExecutionMode', 'fixedRate', 'Period', 0.1, 'TimerFcn', @upTimer);
pause('on');
getchat;%%checks the chat file on the server
decryptloc;%%decrypts the local file(that may have just been downloaded)
start(uptimer);%start those two timers. One executes every seconds the other every 10th of a second
start(polling);

                
uiwait(hChatroom);%pause the state machine

    %gets the version of the chatfile from the server
    function getchat
            cd('chatlog')
            cd(chatname)
            otherdir = pwd;
        filename = [chatname '.csv'];
            try
                
                mget(cftp, filename);
                serverchat = csvread(filename); 
                
            catch%if the file doesn't exist, throws an error dialogue to tell you that 
                msgbox('Unable to retrieve chatlog', 'Error', 'error');
            end
        
    end
 
    %call back for sending messages
    function sendmPB_callback(src, event);
        encrypt;%encrypts the ne wmessage and uploads it
        decryptloc; %decrypts the local file so that you can see the message you just sent
    end

    %call back for sending files
   function sendfPB_callback(src, event);
       [FileName,PathName] = uigetfile('*.*','Select File to Share')%get the file to share

       if PathName ~= 0%%if the cancel button was not pressed
           %%%update the shared file, and then upload the file
            dlmwrite('Shared.csv',double(FileName),'-append');
            mput(cftp, [PathName FileName]);
            mput(cftp,'Shared.csv');
       end

   end
%quits the program
 function quitPB_callback (src, event)
    closereq;
 end
    %%%calls the gui to show the chat history
    function historyPB_callback(src, event)
     cd(workingdir);%have to change to local directory where m file is saved
     readhistory
     cd(otherdir);
    end

    %determines if someone is currently uploading
    function upTimer(src, event)

        serverdetails = dir(cftp);%get server directory information
        cd(workingdir);
        s = struct2cell(serverdetails); %make call from structure
        cd(otherdir);
        s_size = size(s);
        
        for a = 1:s_size(2) %%looks for flag file called upload.dat
            if strcmp(s(1,a), 'upload.dat')
                isotherupload = true;
            else
                isotherupload = false;
            end
        end
    end
%%this function is super important. makes most of the important non-user
%%decisions for what the program will do
function pollingTimer(hObject, eventData)

        serverdetails = dir(cftp);%get server directory information
        localdetails = dir();%get local directory information
        cd(workingdir);
        try %try to build cells out of both directory informations
            s1 = struct2cell(serverdetails);
            s2 = struct2cell(localdetails);
        catch ME
            disp(ME);
            return;
        end
        cd(otherdir);
        s1size =size(s1); %get the size of both cells
        s2size = size(s2);
        %need index values for the chat, the shared, and the history files
        %in the server directory cells
        servindex = 0;
        sharedindex = 0;
        histindex = 0;
        for a = 1:s1size(2)
            if strcmp(s1(1,a), [chatname '.csv'])
                servindex = a;%%%get column index for chatlog
            end
            if strcmp(s1(1,a), 'history.csv')
                histindex = a;%%%get column index for list of history
            end
            if strcmp(s1(1,a), 'Shared.csv')
                sharedindex = a;%%%get column index for list of shared files
            end
        end
        %need indexes for the chat, history, and shared files saved locally
        locindex = 0;
        downloadedindex = 0;
        lochistindex = 0;
        for a = 1:s2size(2)
            if strcmp(s2(1,a), [chatname '.csv'])
                locindex = a;%%%get column index for chatlog
            end
            if strcmp(s2(1,a), 'Shared.csv')
                downloadedindex = a;%%%get column index for shared log
            end
            if strcmp(s2(1,a), 'history.csv')
                lochistindex = a;%%%get column index for history
            end
        end
  
        %gets file sizes for all 6 files listed
        serfilesize = s1{2,servindex};
        locfilesize = s2{3,locindex};
        sharedsize = s1{2, sharedindex};
        downloadsize = s2{3,downloadedindex};
        serhistsize = s1{2,histindex};
        lochistsize = s2{3,lochistindex};
  
        %if the shared folder on the server is larger than the local one,
        %then there is a new file to download someone has shared
        if sharedsize > downloadsize
            getshared;
        end
        
        %if the server chat file is bigger than the local one, that means
        %someone has uploaded a new message and it needs to be downloaded
        if  serfilesize > locfilesize
            decryptserver;
        end
        
        %if the history file on the server is bigger than the local history
        %then another user has truncated the chat on the server(so it will
        %appear smalled and fail the previous test) and made a new hitory
        %file. So download both
        if serhistsize > lochistsize
            mget(cftp, 'history.csv');
            decryptserver;
        end
        
end

    %gets whatever files have been shared on the server
    function getshared
        
        movefile('Shared.csv','oldshared.csv');%change thename of the old shared file
        mget(cftp, 'Shared.csv');%download the new shared file
        
        old = csvread('oldshared.csv');
        new = csvread('Shared.csv');
        chold = char(old);
        strold = cellstr(chold)
        
        chnew = char(new);
        strnew = cellstr(chnew)
        %%determine which lines are different from the two files
        loc = ismember(strnew, strold);
        
        howmany = size(loc)
        
        %%%for all of the files that have been shared but not already
        %%%downloaded, it asks the user if they wish to download it. if
        %%%yes, it attempts to save it to the local chatroom folder
        for a = 1:howmany
            if loc(a) == 0
                choice = questdlg(['Would you like to download ' chnew(a,:) '?'], ...
                'Shared File', ...
                'Yes','No', 'Yes');
                switch choice
                    case 'Yes'
                      pause(2);
                     try
                         
                         mget(cftp, chnew(a,:));
                         pause(2);
                         close(cftp);
                         cftp = ftp(adrs, usrname,usrpswd);
                     catch ME
                          msgbox('Error when downloading file','Error','error');
                          disp(ME);
                     end
                    case 'No'
                 end
            end
        end
        delete('oldshared.csv');
    end

    %function to encrypt new messages being send
    function encrypt
        hentered = findobj('tag', 'msgTB');
        plaintxt = get(hentered, 'String');
        set(hentered, 'String', []);
        user = strcat(usrname, ': ');%%ges the string from the text box and appends the user name to the fron
        plaintxt = strcat(user, plaintxt);
        asciiplain = double(plaintxt);
        
        x = 1;
        blanktxt =  cipher(x);
        for a = 1:length(plaintxt)
                asciiplain(a) = asciiplain(a) + cipher(x);%encodes the ascii values using the cipher from the previous screen
            if mod(x, length(cipher)) == 0 %%repeats the cipher for the length of the string ot be encrypted
                x = 1;
            else
                x = x + 1;
            end;
        end
        dlmwrite([chatname '.csv'],asciiplain,'-append');%%appends message to local chat
        dlmwrite([chatname '.csv'],blanktxt,'-append');
        
        while isotherupload %%if someone else is uploading wait
            
            disp('waiting for upload');
            pause(1);
        end
        
        %creates flag file
        dlmwrite('uploading.dat', [])
        %moves flag to server, uploads chat, deletes flag file from server
        mput(cftp, 'uploading.dat');
        mput(cftp, [chatname '.csv']);
        delete(cftp, 'uploading.dat');

        delete('uploading.dat');%deletes flag file locally

        
    end

    function decryptserver
        %%tries to get get chat file from the server
       try
            mget(cftp, [chatname '.csv']);
       catch
           disp('Unable to get chat from server');
           return;
       end
       serverchat = csvread([chatname '.csv']);
 
        hchat = findobj('tag', 'chatTB');
        sized = size(serverchat);               
  
        %%%nested for loops that decrypt each line of the server file using
        %%%the key entered on the previous screen
        for s = 1:sized(1)
             x = 1;
        
            for a = 1:sized(2)
       
                serverchat(s,a) = serverchat(s,a) - cipher(x);

                if mod(x, length(cipher)) == 0
                    x = 1;
                else
                    x = x + 1;
                end;
            end
        end

        dispchat = char(serverchat);
        screenadj;%%ensures the screen is where we want it
        
    end

%takes the file from the local directory and decrypts it
 function decryptloc
 
        filename = [chatname '.csv'];
        try
            Q = csvread(filename);
        catch
            disp('Unable to decrypt local chat file');
            return;
        end
        sized = size(Q);
  
        %nested for loops to decrypt local version of the chat
        for s = 1:sized(1)
             x = 1;
        
            for a = 1:sized(2)
                Q(s,a) = Q(s,a) - cipher(x);
                if mod(x, length(cipher)) == 0
                    x = 1;
                else
                    x = x + 1;
                end;
            end
        end
        dispchat = char(Q);
        screenadj;
 end
    %keeps the screen where we want it
    function screenadj
        historycheck;%checks that we don't have too many lines of text

       cd(workingdir);
       try%%finds the java object for the chat box and moves it to the bottom
        jeditbox = findjobj(chatboxTB, 'nomenu');
        hdisp = findobj('tag', 'chatTB');
        set(hdisp, 'String', dispchat);
        jVScroll = jeditbox.getVerticalScrollBar;
        jVScroll.setValue(jVScroll.getMaximum);
       catch
       end
        cd(otherdir);
    end

    %this function improves performance by limiting how many lines of text
    %are used by the chat file. 
    function historycheck
       numlines =  size(dispchat);
       if numlines(1) > 200 %%chat is 200 lines
           newhistory = double(dispchat);
           sized = size(newhistory);
  
           %ecode some of it to put into history
            for s = 1:sized(1)
                x = 1;
        
                for a = 1:sized(2)
                    newhistory(s,a) = newhistory(s,a) + cipher(x);
                    if mod(x, length(cipher)) == 0
                        x = 1;
                    else
                        x = x + 1;
                    end;
                end
            end
        
           %write to the history and truncate the chatfile
           dlmwrite('history.csv', newhistory(1:150, :), '-append');
           dlmwrite([chatname '.csv'], newhistory(151:end, :));
           dispchat = dispchat(151:end, :);
            while isotherupload
                pause(0.1);
                disp('waiting on upload');
            end
            %upload the new history and chat file to the server
            mput(cftp, 'history.csv');
            mput(cftp, [chatname '.csv']);
        end
    end
function closereq(hObject, eventdata, handles)
    try %gotta stop these timers or they will keep running after the program ends
        stop(polling);
        stop(uptimer);
    catch
    end
    if nargin == 1
        %%don't change the next state
    else
        state = 5; %%goes to state 5 aka close
    end
    try %%clear out the variables
        clear dispchat
        clear usrpswd
        clear Q
        close(cftp)
        cd(workingdir);
        clearvars
    catch
    end

    delete(gcf);
end
%key press for text box
function KeyPress_Function(h,eventdata,fig)
    %if the user presses the enter key, it acts as if they pressed send
    %message
    drawnow;
    key = get(fig,'currentkey');
    drawnow
    switch key
        case 'return'
            encrypt;
            decryptloc;
            drawnow;
            return;
    end

end
    %stops the timer and send the user back to the select chat screen
    function selectPB_callback(src, event)
        try
         stop(polling);
         stop(uptimer);
        catch
        end
        state = 2;
        close(cftp);
        closereq(src);
    end
    end
