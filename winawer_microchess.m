function winawer_microchess()
    % Winawer Microchess
    % A 4x4 chess variant
    
    % Initialize board
    % 1=Pawn, 2=Bishop, 3=Rook, 4=King, 5=Queen (for promotion)
    % Positive = White, Negative = Black
    board = zeros(4, 4);
    board(1, :) = [ 4,  2,  2,  3]; % White: King, Bishop, Bishop, Rook
    board(2, :) = [ 1,  1,  1,  1]; % White: Pawns
    board(3, :) = [-1, -1, -1, -1]; % Black: Pawns
    board(4, :) = [-4, -2, -2, -3]; % Black: King, Bishop, Bishop, Rook
    
    selected_sq = [];
    game_over = false;
    
    % Create GUI
    f = figure('Name', 'Winawer Microchess', 'NumberTitle', 'off', ...
               'MenuBar', 'none', 'ToolBar', 'none', 'Color', [0.9 0.9 0.9], ...
               'WindowButtonDownFcn', @on_click, 'Position', [300, 300, 500, 500]);
    ax = axes('Parent', f, 'Position', [0.05 0.05 0.9 0.85]);
    hold(ax, 'on');
    axis(ax, 'equal');
    axis(ax, [0.5 4.5 0.5 4.5]);
    set(ax, 'XTick', [], 'YTick', [], 'XColor', 'none', 'YColor', 'none');
    title(ax, 'Winawer Microchess - White''s Turn', 'FontSize', 14, 'FontWeight', 'bold');
    
    draw_board();
    
    % --- Callback for Mouse Clicks ---
    function on_click(~, ~)
        if game_over, return; end
        
        pt = get(ax, 'CurrentPoint');
        col = round(pt(1, 1));
        row = round(pt(1, 2));
        
        % Ensure click is within board
        if row < 1 || row > 4 || col < 1 || col > 4
            return;
        end
        
        if isempty(selected_sq)
            % Select a piece
            if sign(board(row, col)) == 1 % White piece
                selected_sq = [row, col];
                draw_board();
            end
        else
            % Attempt to move or change selection
            if sign(board(row, col)) == 1
                % Changed mind, selected a different white piece
                selected_sq = [row, col];
                draw_board();
            else
                % Try to move to the destination
                moves = get_legal_moves(board, 1);
                move_idx = find(moves(:,1)==selected_sq(1) & moves(:,2)==selected_sq(2) & ...
                                moves(:,3)==row & moves(:,4)==col, 1);
                            
                if ~isempty(move_idx)
                    % Apply valid move
                    board(row, col) = board(selected_sq(1), selected_sq(2));
                    board(selected_sq(1), selected_sq(2)) = 0;
                    
                    % Auto-promote to Queen
                    if board(row, col) == 1 && row == 4
                        board(row, col) = 5; 
                    end
                    
                    selected_sq = [];
                    draw_board();
                    
                    % Computer's Turn
                    pause(0.2); % Slight pause for realism
                    computer_move();
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
        moves = get_legal_moves(board, -1);
        
        if isempty(moves)
            if is_check(board, -1)
                title(ax, 'Checkmate! White Wins!', 'Color', 'b', 'FontSize', 14);
            else
                title(ax, 'Stalemate! Draw!', 'Color', 'k', 'FontSize', 14);
            end
            game_over = true;
            return;
        end
        
        % Pick a random move
        idx = randi(size(moves, 1));
        r1 = moves(idx, 1); c1 = moves(idx, 2);
        r2 = moves(idx, 3); c2 = moves(idx, 4);
        
        % Apply
        board(r2, c2) = board(r1, c1);
        board(r1, c1) = 0;
        
        % Auto-promote to Queen
        if board(r2, c2) == -1 && r2 == 1
            board(r2, c2) = -5;
        end
        
        draw_board();
        
        % Check if White is mated
        w_moves = get_legal_moves(board, 1);
        if isempty(w_moves)
            if is_check(board, 1)
                title(ax, 'Checkmate! Black Wins!', 'Color', 'r', 'FontSize', 14);
            else
                title(ax, 'Stalemate! Draw!', 'Color', 'k', 'FontSize', 14);
            end
            game_over = true;
        else
            if is_check(board, 1)
                title(ax, 'Check! White''s Turn', 'Color', 'r', 'FontSize', 14);
            else
                title(ax, 'White''s Turn', 'Color', 'k', 'FontSize', 14);
            end
        end
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
                    sq_color = [0.5 0.8 0.5]; % Greenish
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
                    
                    % UPDATED: Using 'FontUnits', 'normalized' to scale with the window
                    text(ax, c, r, sym, 'FontUnits', 'normalized', 'FontSize', 0.2, ...
                         'HorizontalAlignment', 'center', ...
                         'VerticalAlignment', 'middle', 'Color', txt_col, 'FontWeight', 'bold');
                end
            end
        end
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