function winawer_microchess()
    % Winawer Microchess
    % A 4x4 chess variant
    
    % Game State Variables
    board = zeros(4, 4);
    selected_sq = [];
    game_over = false;
    human_color = 1;  % 1 for White, -1 for Black
    current_turn = 1; % 1 for White, -1 for Black
    
    % Create GUI
    f = figure('Name', 'Winawer Microchess', 'NumberTitle', 'off', ...
               'MenuBar', 'none', 'ToolBar', 'none', 'Color', [0.9 0.9 0.9], ...
               'WindowButtonDownFcn', @on_click, 'Position', [300, 300, 650, 500]);
               
    % Axes Position
    ax = axes('Parent', f, 'Position', [0.08 0.1 0.6 0.8]);
    hold(ax, 'on');
    axis(ax, 'equal');
    axis(ax, [0.5 4.5 0.5 4.5]);
    
    % X and Y tick labels for files (A-D) and ranks (1-4)
    set(ax, 'XTick', 1:4, 'XTickLabel', {'A', 'B', 'C', 'D'}, ...
            'YTick', 1:4, 'YTickLabel', {'1', '2', '3', '4'}, ...
            'TickLength', [0 0], 'FontSize', 14, 'FontWeight', 'bold', ...
            'XColor', 'k', 'YColor', 'k');
            
    % --- UI Panel Controls ---
    uicontrol('Parent', f, 'Style', 'text', 'String', 'Game Settings', ...
              'Units', 'normalized', 'Position', [0.72 0.75 0.25 0.05], ...
              'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', [0.9 0.9 0.9]);
              
    color_popup = uicontrol('Parent', f, 'Style', 'popupmenu', ...
              'String', {'Play as White', 'Play as Black'}, ...
              'Units', 'normalized', 'Position', [0.72 0.65 0.25 0.08], ...
              'FontSize', 12);
              
    uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'New Game', ...
              'Units', 'normalized', 'Position', [0.72 0.5 0.25 0.1], ...
              'FontSize', 14, 'FontWeight', 'bold', 'Callback', @start_new_game);

    % Start the first game automatically
    start_new_game([], []);

    % --- Core Game Flow Functions ---
    function start_new_game(~, ~)
        % Reset board pieces
        board = zeros(4, 4);
        board(1, :) = [ 4,  2,  2,  3]; % White: King, Bishop, Bishop, Rook
        board(2, :) = [ 1,  1,  1,  1]; % White: Pawns
        board(3, :) = [-1, -1, -1, -1]; % Black: Pawns
        board(4, :) = [-4, -2, -2, -3]; % Black: King, Bishop, Bishop, Rook
        
        selected_sq = [];
        current_turn = 1; % White always moves first in chess
        
        % Read user color preference
        if get(color_popup, 'Value') == 1
            human_color = 1;
        else
            human_color = -1;
        end
        
        draw_board();
        game_over = check_game_over(current_turn);
        
        % If user chose Black, the computer (White) must move first
        if human_color == -1 && ~game_over
            pause(0.5);
            computer_move();
        end
    end

    function is_over = check_game_over(color_to_move)
        moves = get_legal_moves(board, color_to_move);
        is_over = false;
        
        if isempty(moves)
            is_over = true;
            if is_check(board, color_to_move)
                if color_to_move == 1
                    title(ax, 'Checkmate! Black Wins!', 'Color', 'r', 'FontSize', 16);
                else
                    title(ax, 'Checkmate! White Wins!', 'Color', 'b', 'FontSize', 16);
                end
            else
                title(ax, 'Stalemate! Draw!', 'Color', 'k', 'FontSize', 16);
            end
        else
            % Game continues, update title
            if is_check(board, color_to_move)
                if color_to_move == 1
                    title(ax, 'Check! White''s Turn', 'Color', 'r', 'FontSize', 16);
                else
                    title(ax, 'Check! Black''s Turn', 'Color', 'r', 'FontSize', 16);
                end
            else
                if color_to_move == 1
                    title(ax, 'White''s Turn', 'Color', 'k', 'FontSize', 16);
                else
                    title(ax, 'Black''s Turn', 'Color', 'k', 'FontSize', 16);
                end
            end
        end
    end

    % --- Callback for Mouse Clicks ---
    function on_click(~, ~)
        % Ignore clicks if game is over or it's the computer's turn
        if game_over || current_turn ~= human_color
            return; 
        end
        
        pt = get(ax, 'CurrentPoint');
        col = round(pt(1, 1));
        row = round(pt(1, 2));
        
        % Ensure click is within board boundaries
        if row < 1 || row > 4 || col < 1 || col > 4
            return;
        end
        
        if isempty(selected_sq)
            % Select a piece (must belong to human)
            if sign(board(row, col)) == human_color 
                selected_sq = [row, col];
                draw_board();
            end
        else
            % Attempt to move or change selection
            if sign(board(row, col)) == human_color
                % Changed mind, selected a different friendly piece
                selected_sq = [row, col];
                draw_board();
            else
                % Try to move to the destination square
                moves = get_legal_moves(board, human_color);
                move_idx = find(moves(:,1)==selected_sq(1) & moves(:,2)==selected_sq(2) & ...
                                moves(:,3)==row & moves(:,4)==col, 1);
                            
                if ~isempty(move_idx)
                    % Apply valid human move
                    board(row, col) = board(selected_sq(1), selected_sq(2));
                    board(selected_sq(1), selected_sq(2)) = 0;
                    
                    % Auto-promote to Queen
                    if board(row, col) == 1 && row == 4
                        board(row, col) = 5; 
                    elseif board(row, col) == -1 && row == 1
                        board(row, col) = -5;
                    end
                    
                    selected_sq = [];
                    current_turn = -human_color; % Switch turns
                    draw_board();
                    
                    % Check game state, if not over, trigger computer AI
                    game_over = check_game_over(current_turn);
                    if ~game_over
                        computer_move();
                    end
                else
                    % Invalid move, deselect
                    selected_sq = [];
                    draw_board();
                end
            end
        end
    end

    % --- Computer AI (Random Legal Move) ---
    function computer_move()
        moves = get_legal_moves(board, current_turn);
        if isempty(moves)
            return; % Safety check
        end
        
        % Pick a random move
        idx = randi(size(moves, 1));
        r1 = moves(idx, 1); c1 = moves(idx, 2);
        r2 = moves(idx, 3); c2 = moves(idx, 4);
        
        % 1. Highlight the piece about to be moved
        selected_sq = [r1, c1];
        draw_board();
        pause(0.6); % Brief delay before moving
        
        % Apply move
        board(r2, c2) = board(r1, c1);
        board(r1, c1) = 0;
        
        % Auto-promote to Queen
        if board(r2, c2) == 1 && r2 == 4
            board(r2, c2) = 5; 
        elseif board(r2, c2) == -1 && r2 == 1
            board(r2, c2) = -5;
        end
        
        % 2. Highlight the destination square
        selected_sq = [r2, c2];
        draw_board();
        pause(0.6); % Brief delay after moving
        
        % Pass turn back to human
        selected_sq = [];
        current_turn = human_color;
        draw_board();
        
        % Check if the human is mated or stalemated
        game_over = check_game_over(current_turn);
    end

    % --- Board Drawing ---
    function draw_board()
        cla(ax);
        light_col = [0.9 0.8 0.7];
        dark_col = [0.4 0.3 0.2];
        
        for r = 1:4
            for c = 1:4
                % Alternating colors
                if mod(r+c, 2) == 1
                    sq_color = dark_col;
                else
                    sq_color = light_col;
                end
                
                % Highlight selected square
                if ~isempty(selected_sq) && selected_sq(1)==r && selected_sq(2)==c
                    if current_turn == human_color
                        sq_color = [0.5 0.8 0.5]; % Greenish for human
                    else
                        sq_color = [0.9 0.7 0.4]; % Orange for computer
                    end
                end
                
                rectangle(ax, 'Position', [c-0.5, r-0.5, 1, 1], 'FaceColor', sq_color, 'EdgeColor', 'k');
                
                % Draw piece
                piece = board(r, c);
                if piece ~= 0
                    sym = get_piece_symbol(piece);
                    % Choose text color based on piece color
                    if piece > 0
                        txt_col = 'w'; % White pieces
                    else
                        txt_col = 'k'; % Black pieces
                    end
                    
                    % Using 'FontUnits', 'normalized' to scale with the window
                    text(ax, c, r, sym, 'FontUnits', 'normalized', 'FontSize', 0.2, ...
                         'HorizontalAlignment', 'center', ...
                         'VerticalAlignment', 'middle', 'Color', txt_col, 'FontWeight', 'bold');
                end
            end
        end
        % Force MATLAB to immediately draw the updates to the UI
        drawnow; 
    end

    function sym = get_piece_symbol(val)
        % Using standard unicode chess symbols
        switch val
            case 1,  sym = char(9823); % Pawn
            case 2,  sym = char(9821); % Bishop
            case 3,  sym = char(9820); % Rook
            case 4,  sym = char(9818); % King
            case 5,  sym = char(9819); % Queen (Promotion)
            case -1, sym = char(9823); % Pawn
            case -2, sym = char(9821); % Bishop
            case -3, sym = char(9820); % Rook
            case -4, sym = char(9818); % King
            case -5, sym = char(9819); % Queen (Promotion)
            otherwise, sym = '';
        end
    end

    % --- Move Generation Rules ---
    function moves = get_legal_moves(b, color)
        pseudo = get_pseudo_legal_moves(b, color);
        moves = [];
        for i = 1:size(pseudo, 1)
            % Simulate move
            temp_b = b;
            temp_b(pseudo(i,3), pseudo(i,4)) = temp_b(pseudo(i,1), pseudo(i,2));
            temp_b(pseudo(i,1), pseudo(i,2)) = 0;
            
            % If it doesn't leave own king in check, it's legal
            if ~is_check(temp_b, color)
                moves = [moves; pseudo(i,:)];
            end
        end
    end

    function in_check = is_check(b, color)
        % See if enemy can attack own King
        king_val = color * 4;
        [kr, kc] = find(b == king_val, 1);
        if isempty(kr)
            in_check = false; % King captured (shouldn't happen)
            return;
        end
        
        enemy_moves = get_pseudo_legal_moves(b, -color);
        in_check = false;
        if ~isempty(enemy_moves)
            % If any enemy move lands on king's square
            if any(enemy_moves(:,3) == kr & enemy_moves(:,4) == kc)
                in_check = true;
            end
        end
    end

    function moves = get_pseudo_legal_moves(b, color)
        moves = [];
        for r = 1:4
            for c = 1:4
                if sign(b(r,c)) == color
                    p_type = abs(b(r,c));
                    switch p_type
                        case 1 % Pawn
                            dir = color; % White moves up (+1), Black moves down (-1)
                            nr = r + dir;
                            if nr >= 1 && nr <= 4
                                % Forward move (only if empty)
                                if b(nr, c) == 0
                                    moves = [moves; r, c, nr, c];
                                end
                                % Captures (diagonals)
                                if c > 1 && sign(b(nr, c-1)) == -color
                                    moves = [moves; r, c, nr, c-1];
                                end
                                if c < 4 && sign(b(nr, c+1)) == -color
                                    moves = [moves; r, c, nr, c+1];
                                end
                            end
                            
                        case 2 % Bishop
                            moves = [moves; get_sliding_moves(b, r, c, color, [1,1; 1,-1; -1,1; -1,-1])];
                            
                        case 3 % Rook
                            moves = [moves; get_sliding_moves(b, r, c, color, [1,0; -1,0; 0,1; 0,-1])];
                            
                        case 5 % Queen
                            moves = [moves; get_sliding_moves(b, r, c, color, [1,1; 1,-1; -1,1; -1,-1; 1,0; -1,0; 0,1; 0,-1])];
                            
                        case 4 % King
                            dirs = [1,1; 1,-1; -1,1; -1,-1; 1,0; -1,0; 0,1; 0,-1];
                            for d = 1:8
                                nr = r + dirs(d,1); nc = c + dirs(d,2);
                                if nr >= 1 && nr <= 4 && nc >= 1 && nc <= 4
                                    if sign(b(nr,nc)) ~= color
                                        moves = [moves; r, c, nr, nc];
                                    end
                                end
                            end
                    end
                end
            end
        end
    end

    function s_moves = get_sliding_moves(b, r, c, color, dirs)
        s_moves = [];
        for d = 1:size(dirs, 1)
            nr = r + dirs(d,1);
            nc = c + dirs(d,2);
            while nr >= 1 && nr <= 4 && nc >= 1 && nc <= 4
                if b(nr,nc) == 0
                    s_moves = [s_moves; r, c, nr, nc];
                elseif sign(b(nr,nc)) == -color
                    s_moves = [s_moves; r, c, nr, nc];
                    break; % Can capture but can't move further
                else
                    break; % Blocked by own piece
                end
                nr = nr + dirs(d,1);
                nc = nc + dirs(d,2);
            end
        end
    end
end