function chat
global usrname;
global usrpswd;
global adrs;
global state;
global chatname;
global cipher;
global workingdir;
global cftp;

workingdir = pwd;

%make a folder for the chatlogs if it doesn't exist
if exist('chatlog', 'file') ~= 7
    mkdir('chatlog');
end


%start the state machine
state = 1;
while(true)

    if state == 1
            login %login gui
       
    elseif state == 2
            selectchat%chat select gui
        
    elseif state == 3
            password%enter the key
        
    elseif state == 4
        
            chatroom%where all the magic happens
        
    elseif state==5
        %user pressed quit, this is the quit state
        %breaks out of the infinite loop of the state machine
        break;
    else
        %seriously, this shouldn't ever execute
        uiwait(msgbox('Statemachine is in an invalid state, closing program.', 'Error', 'error'));
        break;
    end;

end
end