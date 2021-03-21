function password
global state;
global cipher;

hPass = figure('Units','Pixels',...
                'Position', [500 400 350 100],...
                'MenuBar','none',...
                'ToolBar','none',...
                'Resize', 'off',...
                'CloseRequestFcn',@closereq,...
                'Name', 'Enter the Password');
            
p = uipanel(hPass,'Position',[.02 .02 .96 .96]);
%%%initalizing uicontrols

enterPB = uicontrol(p,'Style','pushbutton',...
                    'String','Enter',...
                    'Units','normalized',...
                    'FontSize',10,...
                    'Callback',@enterPB_callback,...
                    'Position',[.05 .05 .35 .25]);
                
cancelPB = uicontrol(p,'Style','pushbutton',...
                    'String','Cancel',...
                    'Units','normalized',...
                    'FontSize',10,...
                    'Callback',@cancelPB_callback,...
                    'Position',[.6 .05 .35 .25]);
                
promptST = uicontrol(p,'Style','text',...
                    'String','Chatroom Password:',...
                    'FontSize',12,...
                    'Units','normalized',...
                    'Position',[.0 .425 .6 .3]);
                
passTB = uicontrol(p,'Style','edit',...
                    'String','pass',...
                    'tag','passTB',...
                    'FontSize',10,...
                    'Units','normalized',...
                    'KeyPressfcn',{@KeyPress_Function,hPass},...
                    'Position',[.53 .46 .43 .3]);
uiwait(hPass);
%%%end uicontrol initalization
function cancelPB_callback (src, event)
    state = 2; %%goes to state 2 aka select chatroom
    fig = ancestor(src, 'figure');
    uiresume(fig);
    closereq(src);
end
function enterPB_callback (src, event)
    state = 4; %%goes to state 4 aka chatroom
    hval = findobj('tag', 'passTB');
    fig = ancestor(src, 'figure');
    key = get(hval, 'String');
    
    cipher = double(key);%%turns the string into ascii values
    for b = 1:length(cipher)
            cipher(b) = cipher(b) - 32; %%the lowest used ascii value is 'space' or 32
    end
    %our key is now offset by space as the lowest value possible
    
    uiresume(fig);
    closereq(src);
end
function closereq(hObject, eventdata, handles)
    if nargin == 1
        %%don't change the next state
    else
        state = 5; %%goes to state 5 aka close
    end
    delete(gcf);
end

%if the user presses enter while selecting the textbox, it calls the enter
%button's callback
function KeyPress_Function(h,eventdata,fig)

    drawnow;
    key = get(fig,'currentkey');
    drawnow
    switch key
        case 'return'
            enterPB_callback(h, eventdata);
            drawnow;
            return;
    end

end
end