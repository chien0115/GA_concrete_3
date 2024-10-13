function [YY1, YY2, best_dispatch_times] = selection(P, E, s, dispatch_times,L)
    [x, y] = size(P); % 目前经历过 crossover、mutation 的 P
    YY1 = zeros(s, y); % 储存良好的染色体
    YY2 = zeros(s, 1); % 良好的适应值
    best_dispatch_times = zeros(s, size(dispatch_times, 2)); % Store dispatch times
    e = min(round(s / 4), x); % Number of elite chromosomes to select, 确保不超过现有染色体数量
    %E暫時適存值 L:在現有族群中最大之F值 F:染色體之真實適存值

    F = L - E; % 计算真实适存值：暂时适存值越小，真实适存值越大
    
    % Elite selection
    for i = 1:e
        c1 = find(F == max(F), 1); % Find index of the best fitness value
        
        % Store selected chromosome, fitness value, and dispatch times
        YY1(i, :) = P(c1, :);
        YY2(i) = F(c1);
        best_dispatch_times(i, :) = dispatch_times(c1, :);
        
        % Remove selected chromosome from population
        P(c1, :) = [];
        F(c1) = [];
        dispatch_times(c1, :) = [];
        
        % 更新维度
        [x, ~] = size(P);
        
        % 确保在选择过程中不超出染色体数量
        if x == 0
            break;
        end
    end
    
    % 如果精英选择已经选够了所需的染色体，直接返回
    if e >= s
        YY1 = YY1(1:s, :);
        YY2 = YY2(1:s);
        best_dispatch_times = best_dispatch_times(1:s, :);
        return;
    end
    
    % Selection based on fitness probabilities for remaining chromosomes
    remaining = s - e;
    if x > 0 && remaining > 0
        D = F / sum(F); % Fitness proportionate selection
        CP = cumsum(D); % Cumulative probabilities
        
        for i = 1:remaining
            N = rand(1); % Random number for selection
            idx = find(CP >= N, 1);
            if isempty(idx)
                idx = length(CP); % 如果没有找到合适的索引，选择最后一个
            end
            
            YY1(e+i, :) = P(idx, :);
            YY2(e+i) = F(idx);
            best_dispatch_times(e+i, :) = dispatch_times(idx, :);
        end
    end
    
    % 如果选择的染色体数量不足，用原始人口中的染色体随机填充
    if size(YY1, 1) < s
        remaining = s - size(YY1, 1);
        original_indices = randperm(size(P, 1), remaining);
        YY1(end+1:s, :) = P(original_indices, :);
        YY2(end+1:s) = F(original_indices);
        best_dispatch_times(end+1:s, :) = dispatch_times(original_indices, :);
    end
end