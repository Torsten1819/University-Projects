

function RunGame
    global pNamevar;
    global pColorvar;
    global pTimer;
    global iniTimer;
    global rightScore;
    global leftScore;
    global sound1;
    global samp1;
    global samp2;
    global sound2;
    
   [sound1 samp1] = audioread('pongwav1.wav');
   [sound2 samp2] = audioread('pongwav2.wav');

    rightScore = 0;
    leftScore = 0;
    

    hMainWindow = figure(...
        'Color', [0 0 0],...
        'Name', 'Game Window',...
        'Units', 'pixels',...
        'Position',[100 100 700 500]);


    
    img = imread('ball.bmp','bmp');
    [m,n,c] = size(img);
    hBall = axes(...
        'parent', hMainWindow,...
        'color', 'none',...
        'visible', 'off',...
        'units', 'pixels',...
        'position', [345, 245, n, m] );
    hBallImage = imshow( img );
    set(hBallImage, 'parent', hBall, 'visible', 'off' );
    ballSpeed = 0;
    ballDirection = 0;
    hTempBall = axes( ...
        'parent', hMainWindow,...
        'units', 'pixels',...
        'color', 'none',...
        'visible', 'off',...
        'position', get(hBall, 'position' ) );
    
    player_subgui();
    
    img = imread('paddle.bmp','bmp');
    [m,n,c] = size(img);
    img(:,:,1) = 255;
    img(:,:,2) = 255;
    img(:,:,3) = 0;
    hRightPaddle = axes(...
        'parent', hMainWindow,...
        'color', 'none',...
        'visible', 'off',...
        'units', 'pixels',...
        'position', [650 - 10, 250 - 50, n, m] );
    hRightPaddleImage = imshow( img );
    set(hRightPaddleImage, 'parent', hRightPaddle, 'visible', 'off' );
    targetY = 200;
    t = timer(  'TimerFcn', @UpdateRightPaddleAI,...
                'StartDelay', .3 );
            start(t)
    t2 = timer('ExecutionMode', 'fixedRate', 'TimerFcn', @updateTimer);
    %%%reset image color
    if pColorvar == 1;
        img(:,:,1) = 0;
        img(:,:,2) = 191;
        img(:,:,3) = 255;
    elseif pColorvar == 2;
        img(:,:,2:3) = 0;
        img(:,:,1) = 255;
    else
        img(:,:,1:3) = 0;
        img(:,:,2) = 255;
    end;

      
    hLeftPaddle = axes(...
        'parent', hMainWindow,...
        'color', 'none',...
        'visible', 'off',...
        'units', 'pixels',...
        'position', [50, 250 - 50, n, m] );
    hLeftPaddleImage = imshow( img );
    set(hLeftPaddleImage, 'parent', hLeftPaddle, 'visible', 'off' );

    hBottomWall = axes(...
        'parent', hMainWindow,...
        'color', [1 1 1],...
        'units', 'pixels',...
        'visible', 'off',...
        'position', [0 40 700 10] );
    patch( [0 700 700 0], [0 0 10 10], 'b' );    
    
    hTopWall = axes(...
        'parent', hMainWindow,...
        'color', [1 1 1],...
        'units', 'pixels',...
        'visible', 'off',...
        'position', [0 450 700 10] );
    patch( [0 700 700 0], [0 0 10 10], 'b' );
    
     
    
    hQuitButton = uicontrol(...
        'string', 'Quit',...
        'position', [515 120 70 30],...
        'visible', 'off',...
        'fontsize', 12,...
        'Callback', @QuitButton_CallBack );
    hContinueButton = uicontrol(...
        'string', 'Continue',...
        'position', [315 120 70 30],...
        'visible','off',...
        'fontsize', 12,...
        'Callback', @ContinueButton_CallBack );
    hRestartButton = uicontrol(...
        'string', 'Restart',...
        'position', [115 120 70 30],...
        'visible','off',...
        'fontsize', 12,...
        'Callback', @RestartButton_CallBack );
    
    hStartButton = uicontrol(...
        'string', 'Start',...
        'position', [325 240 50 20],...
        'Callback',@StartButton_CallBack );
    

    hPlayerName = uicontrol('Style','text',...
        'Position',[40 466 180 25],...
        'BackgroundColor', [0 0 0],...
        'foregroundcolor', 'w',...
        'fontsize', 14,...
        'String',pNamevar);
    
     hComName = uicontrol('Style','text',...
        'Position',[500 466 90 25],...
        'BackgroundColor', [0 0 0],...
        'foregroundcolor', 'w',...
        'fontsize', 14,...
        'String','Computer');
    
     hClock = uicontrol('Style','text',...
        'Position',[330 470 40 25],...
        'BackgroundColor', [0 0 0],...
        'foregroundcolor', 'w',...
        'HorizontalAlignment', 'center',...
        'fontsize', 16,...
        'String',pTimer);

    hWinner1 = uicontrol('Style','text',...
        'Position',[0 300 700 40],...
        'BackgroundColor', [0 0 0],...
        'foregroundcolor', 'w',...
        'HorizontalAlignment', 'center',...
        'visible', 'off',...
        'fontsize', 26,...
        'String',pNamevar);
    hWinner2 = uicontrol('Style','text',...
        'Position',[0 230 700 40],...
        'BackgroundColor', [0 0 0],...
        'foregroundcolor', 'w',...
        'HorizontalAlignment', 'center',...
        'visible', 'off',...
        'fontsize', 26,...
        'String','Wins');
    
    hRightScoreText = uicontrol('Style','text',...
                    'Position',[650 470 50 20],...
                    'BackgroundColor', [0 0 0],...
                    'foregroundcolor', 'w',...
                    'fontsize', 14,...
                    'String',num2str(rightScore));

    hLeftScoreText = uicontrol('Style','text',...
                    'Position',[30 470 50 20],...
                    'BackgroundColor', [0 0 0],...
                    'foregroundcolor', 'w',...
                    'fontsize', 14,...
                    'String',num2str(leftScore));
 
     
    
    function UpdateBall
        
       pos = get( hBall, 'position' );
       ballX = pos(1,1);
       ballY = pos(1,2);
       
       ballDirection = NormalizeAngle( ballDirection );
      
       
       % check for collisions with the walls
       if ( ballY > 450 - 10 ) && ( ballDirection > 0 ) && ( ballDirection < 180 )
            sound(sound2, samp2);
            if ( ballDirection > 90 )
                ballDirection = ballDirection + 2 * ( 180 - ballDirection );
            else
                ballDirection = ballDirection - 2 * ballDirection;
            end
       elseif ( ballY < 50 ) && ( ballDirection > 180 ) && ( ballDirection < 360 )
           sound(sound2, samp2);
            if ( ballDirection > 270 )
                ballDirection = ballDirection + 2 * ( 360 - ballDirection );
            else
                ballDirection = ballDirection - 2 * ( ballDirection - 180 );
            end
       end
       
       % check for collisions with the paddles
       
       if ( ballDirection > 90 && ballDirection < 270 )
           
            leftPaddlePos = get( hLeftPaddle, 'position' );
            leftX = leftPaddlePos(1,1);
            leftY = leftPaddlePos(1,2);
          
            if(     (ballX < leftX + 10)...
                &&  (ballX > leftX + 5)...
                &&  (ballY + 10 > leftY)...
                &&  (ballY < leftY + 100)     )
                sound(sound1, samp1);
                if ( ballDirection < 180 )
                    ballDirection = 180 - ballDirection;
                elseif( ballDirection > 180 )
                    ballDirection = 180 - ballDirection;
                end
            end
       else
            rightPaddlePos = get( hRightPaddle, 'position' );
            rightX = rightPaddlePos(1,1);
            rightY = rightPaddlePos(1,2);
            
            if(     (ballX + 10 > rightX)...
                &&  (ballX + 10 < rightX + 5)...
                &&  (ballY > rightY)...
                &&  (ballY < rightY + 100)  )
                sound(sound1, samp1);
                if ( ballDirection < 90 )
                    ballDirection = 180 - ballDirection;
                elseif( ballDirection > 270 )
                    ballDirection = 180 - ballDirection;
                end
            end
       end
           
       MoveObject( hBall, ballSpeed, ballDirection );
        
    end


    
    function UpdateRightPaddle()

         
         speed = 5;
         pos = get( hRightPaddle, 'position' );
         rightY = pos(1,2);
         
         
         
         if( rightY + 5 < targetY - 50 && rightY < 400 - 50 )
             MoveObject( hRightPaddle, speed, 90 )
         elseif( rightY - 5 > targetY - 50 && rightY > 50 )
             MoveObject( hRightPaddle, speed, 270 )
         end
      
         pos = get( hRightPaddle, 'position' );
         rightY = pos( 1,2);
         if( rightY > 400 - 50 )
             rightY = 350;
         elseif( rightY < 50 )
             rightY = 50;
         end
         
         
        if( strcmp( get( t, 'Running' ), 'off' ) )
            start(t)
        end
    
    end

    function UpdateRightPaddleAI( ob, data )
        
        % calculate where the ball will colide.
        tempBallDirection = NormalizeAngle( ballDirection ); 
        if( tempBallDirection < 90 || tempBallDirection > 270 && ballSpeed > 0 )
           
            ballPos = get( hBall, 'position' );
            set( hTempBall, 'position', ballPos );
            ballX = ballPos(1,1);            
            while( ballX < 650 - 10  )
                
                ballPos = get( hTempBall, 'position' );
                ballX = ballPos(1,1); 
                ballY = ballPos(1,2);
                MoveObject( hTempBall, 20, tempBallDirection )

               % check for temp ball collision with walls.
               if ( ballY > 450 - 10 ) 
                   if ( tempBallDirection > 0 ) 
                       if ( tempBallDirection < 180 )    
                            tempBallDirection = 360 - tempBallDirection;
                       end
                   end
               elseif ( ballY < 60 ) 
                   if( tempBallDirection > 180 ) 
                       if( tempBallDirection < 360 )
                            tempBallDirection = 360 - tempBallDirection;
                       end
                   end
               end

%                     line( 0, 0, 'marker', '*', 'parent', hTempBall )
%                     pause( 0.0005 )
            end

            pos = get( hTempBall, 'position' );
            ballY = pos(1,2);
            targetY = ballY + ( rand * 150 ) - 75;
            
        end
    end

    function UpdateLeftPaddle()    
        scr = get( hMainWindow, 'position' );
        screenX = scr(1,1);
        screenY = scr(1,2);
        screenH = scr(1,4);
        
        mouse = get(0, 'PointerLocation' );
        y = mouse(1,2) - screenY;
        
        if( y > 100 && y < 400 )
            paddlePos = get( hLeftPaddle, 'position' ); 
            paddlePos(1,2) = y - 50; 
            set( hLeftPaddle, 'position', paddlePos );
        elseif( y > 400 )
            paddlePos = get( hLeftPaddle, 'position' ); 
            paddlePos(1,2) = 400 - 50; 
            set( hLeftPaddle, 'position', paddlePos ); 
        elseif( y < 100 )
            paddlePos = get( hLeftPaddle, 'position' ); 
            paddlePos(1,2) = 100 - 50; 
            set( hLeftPaddle, 'position', paddlePos );
        end
        
    end

    function CheckForScore()
        
       pos = get( hBall, 'position' );
       xpos = pos(1,1);
       ypos = pos(1,2);
       
       if ( xpos < 5 )
           sound(audioread('pongwav3.wav'), 25000);
           set( hBallImage, 'visible', 'off' )
           rightScore = rightScore + 1;
           set ( hRightScoreText, 'string', num2str( rightScore ) )
           pause( .4 )
           ResetBall()
       elseif ( xpos + 10 > 695 )
           sound(audioread('pongwav3.wav'), 25000);
           set( hBallImage, 'visible', 'off' )
           leftScore = leftScore + 1;
           set ( hLeftScoreText, 'string', num2str( leftScore ) )

           pause( .4 )
           ResetBall()
       end
       
    end
        
    function ResetBall
        
        pos = get( hBall, 'position' );
        pos(1,1) = 345;
        pos(1,2) = 255 + floor( rand*100 ) - 50;
        set( hBall, 'position', pos )
        ballSpeed = 5;
        ballDirection =  ( (rand(1) < 0.5) * 180 ) ...          % 0 or 180
                       + ( 45 + (rand(1) < 0.5) * -90 ) ...     % + 45 or - 45
                       + ( floor( rand * 40 ) - 20 );           % + -20 to 20
        set( hBallImage, 'visible', 'on' )
        pause(1)
        UpdateBall()
        
        
    end
    



    function MoveObject( hInstance, speed, direction )

        p = get( hInstance, 'position' );

        x = p( 1, 1 );
        y = p( 1, 2 );
        
        x = x + cosd( direction ) * speed;
        y = y + sind( direction ) * speed;

        p( 1, 1 ) = x;
        p( 1, 2 ) = y;

        set( hInstance, 'position', p )

    end

    function SetObjectPosition( hObject, x, y )
       
       pos = get( hObject, 'position' );
       pos(1,1) = x;
       pos(1,2) = y;
       set( hObject, 'position', pos )
        
    end

    function a = NormalizeAngle( angle )
        
        while angle > 360
            angle = angle - 360;
        end
        
        while angle < 0
            angle = angle + 360;
        end
        a = angle;

    end

    function QuitButton_CallBack( hObject, eventData )
        delete(t);
        delete(t2);
        close all;
    end

    function ContinueButton_CallBack( hObject, eventData )
        pTimer = iniTimer;
        pause(.5);
        set(hClock, 'String', pTimer);
        set(hQuitButton, 'visible', 'off');
        set(hContinueButton, 'visible', 'off');
        set(hRestartButton, 'visible', 'off');
        set(hWinner1, 'visible', 'off');
        set(hWinner2, 'visible', 'off');
        startGame();
    end

    function RestartButton_CallBack( hObject, eventData )
        close all;
        Pong
    end

    function updateTimer(hObject, eventData)
        pTimer = pTimer -1;
        if pTimer >= 0;
            set(hClock, 'String', pTimer);
        end
    end;
    function endgamecheck(hObject, eventData)
            set(hRightPaddleImage, 'visible', 'off');
            set(hLeftPaddleImage, 'visible', 'off');
            set(hBallImage, 'visible', 'off');
            
        if leftScore > rightScore;
            set(hWinner1, 'visible', 'on');
            set(hWinner2, 'visible', 'on');
        elseif rightScore > leftScore;
            set(hWinner1, 'String', 'Computer');
            set(hWinner1, 'visible', 'on');
            set(hWinner2, 'visible', 'on');
        else
            set(hWinner1, 'String', 'Tie');
            set(hWinner2, 'String', 'Game');
            set(hWinner1, 'visible', 'on');
            set(hWinner2, 'visible', 'on');
        end
        
           set(hQuitButton, 'visible', 'on');
           set(hContinueButton, 'visible', 'on');
           set(hRestartButton, 'visible', 'on');
           
    end;
    function startGame(hObject, eventData)
        set( hLeftPaddleImage, 'visible', 'on' )
        set( hRightPaddleImage, 'visible', 'on' )
        set(hBallImage, 'visible', 'on')
        ResetBall();
        start(t2);
         while  pTimer > 0
             UpdateBall();
             pause(.01);
             UpdateLeftPaddle();
             UpdateRightPaddle();
             CheckForScore();           
         end
         stop(t2);
         endgamecheck();
    end;
    
    function StartButton_CallBack( hObject, eventData )
        set( hObject, 'visible', 'off' );
        startGame();
    end

%%%Child frame for name and choosing paddle color
    function [f] = player_subgui()
        f = figure(...
            'units','pixels',...
            'Color', [0 0 0],...
            'Name', 'Player Select',...
            'menubar','none',...
            'Tag', 'subgui',...
            'position',[250 300 280 300]); % Create a new GUI.
        
    %%%Makes 3 bars of different colors   
    img = imread('paddle.bmp','bmp');
    [m,n,c] = size(img);
    
    img(:,:,1) = 0;
    img(:,:,2) = 191;
    img(:,:,3) = 255;
    hBluePaddle = axes(...
        'parent', f,...
        'color', 'none',...
        'visible', 'off',...
        'units', 'pixels',...
        'position', [70,  150, n, m] );
  
    hPaddleImage = imshow( img );
    set(hPaddleImage, 'parent', hBluePaddle, 'visible', 'on' );
    
    img(:,:,2:3) = 0;
    img(:,:,1) = 255;
    hRedPaddle = axes(...
        'parent', f,...
        'color', 'none',...
        'visible', 'off',...
        'units', 'pixels',...
        'position', [140,  150, n, m] );
  
    hPaddleImage = imshow( img );
    set(hPaddleImage, 'parent', hRedPaddle, 'visible', 'on' );
    
    img(:,:,1:3) = 0;
    img(:,:,2) = 255;
    hGreenPaddle = axes(...
        'parent', f,...
        'color', 'none',...
        'visible', 'off',...
        'units', 'pixels',...
        'position', [210,  150, n, m] );
  
    hPaddleImage = imshow( img );
    set(hPaddleImage, 'parent', hGreenPaddle, 'visible', 'on' );
    
    
  %%% Displays text for name and such      
       playerName = uicontrol('style','edit',...
              'units','pixels',...
              'position',[180 70 80 20],...
              'tag','pname',...
              'string','Player 1');
       
       Nametxt = uicontrol('Style','text',...
        'Position',[0 68 180 25],...
        'BackgroundColor', [0 0 0],...
        'foregroundcolor', 'w',...
        'fontsize', 14,...
        'String','Enter Player Name');
    
       Paddletxt = uicontrol('Style','text',...
        'Position',[50 270 180 25],...
        'BackgroundColor', [0 0 0],...
        'foregroundcolor', 'w',...
        'fontsize', 14,...
        'String','Select a paddle');
    
      Timetxt = uicontrol('Style','text',...
        'Position',[6 22 100 25],...
        'BackgroundColor', [0 0 0],...
        'foregroundcolor', 'w',...
        'fontsize', 14,...
        'String','Time Limit');
    
    %%%selection radio buttons
handles.radio1 = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio1, ...
                           'Units',    'pixels', ...
                           'Position', [67, 120, 14, 14], ...
                           'BackgroundColor', [0 0 0],...
                           'tag','radio1',...
                           'Value',    0);
handles.radio2 = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio2, ...
                           'Units',    'pixels', ...
                           'Position', [137, 120, 14, 14], ...
                           'BackgroundColor', [0 0 0],...
                           'tag','radio2',...
                           'Value',    0);
handles.radio3 = uicontrol('Style', 'radiobutton', ...
                           'Callback', @myRadio3, ...
                           'Units',    'pixels', ...
                           'Position', [207, 120, 14, 14], ...
                           'BackgroundColor', [0 0 0],...
                           'tag','radio3',...
                           'Value',    0);
%%%apply button

handles.applybtn = uicontrol('Style','pushbutton',...
                            'Callback',@applybtn_callback,...
                            'Position', [170 20 100 30],...
                            'String', 'Start the game' );
                        
handles.timer = uicontrol('Style', 'popup',...
                   'String', {'30','60','90','120','180','240','300'},...
                   'tag', 'timers',...
                   'Position', [110 -4 50 50]); 
        

        uiwait(f);
           
    end



        %%%This makes the radio buttons mutually exclusive
        function myRadio1(hObject, eventdata, handles)
            handle2 = findobj( 'tag','radio2' );
            handle3 = findobj( 'tag','radio3' );
            set(handle2, 'Value', 0);
            set(handle3, 'Value', 0);
        end
        function myRadio2(hObject, eventdata, handles)
            handle1 = findobj( 'tag','radio1' );
            handle3 = findobj( 'tag','radio3' );
            set(handle1, 'Value', 0);
            set(handle3, 'Value', 0);
        end
        function myRadio3(hObject, eventdata, handles)
            handle2 = findobj( 'tag','radio2' );
            handle1 = findobj( 'tag','radio1' );
            set(handle2, 'Value', 0);
            set(handle1, 'Value', 0);
        end
    
        function applybtn_callback(hObject, eventdata, handles)

            fig = ancestor(hObject, 'figure');
            
            handle3 = findobj( 'tag','radio3' );                       
            handle2 = findobj( 'tag','radio2' );
            handle1 = findobj( 'tag','radio1' );
            handlename = findobj('tag','pname');
            handletime = findobj('tag', 'timers');
            
            switch get(handletime, 'Value')
                case 1
                    pTimer = 30;                   
                case 2
                    pTimer = 60;
                case 3
                    pTimer = 90;
                case 4
                    pTimer = 120;
                case 5
                    pTimer = 180;
                case 6
                    pTimer = 240;
                otherwise
                    pTimer = 300;
            end
            iniTimer = pTimer;
            pNamevar = get(handlename, 'String');
            rad1 = get(handle1, 'Value');
            rad2 = get(handle2, 'Value');
            rad3 = get(handle3, 'Value');
            
            if rad1 == 1
                pColorvar = 1;
            end;
            if rad2== 1
                pColorvar = 2;
            end;
            if rad3 == 1
                pColorvar = 3;
            end;
            
            if (rad1 == 0 && rad2 == 0 && rad3 == 0);
                msgbox('Please Select a Paddle');
            else
                          uiresume(fig);
                            close(fig);  
            end
            

        end
end