function [Y, dispatch_times_new2] = mutation(P, t, dispatch_times)
    % P = Population
    % dispatch_times = Matrix of dispatch times corresponding to the chromosomes

    [x1, y1] = size(P); % Population size (x1) and chromosome length (y1)
    
    % 隨機選擇一個染色體
    r1 = randi(x1); % 隨機選擇族群內的索引
    A1 = P(r1, 1:y1); % 取出選中的染色體 (派遣順序)
    dispatch_times1 = dispatch_times(r1, :); % 取出對應的派遣時間


    random_number1 = rand();
    random_number2 = rand();

    % 定義派遣順序的突變位置（無奇數位置限制）
    pos1=ceil(random_number1*y1);
    pos2=ceil(random_number2*y1);
    % 交換所選位置的值（調整派遣順序）
    
    while A1(pos1) == A1(pos2)
    % 如果相同，隨機選擇新的位置
    pos2 = ceil(rand() * y1); % 使用 rand() 隨機生成新的 pos2
    end
    
    A1([pos1, pos2]) = A1([pos2, pos1]);

    A2=A1;
    % 同時對派遣時間進行突變
    if t >= 2
        pos_dispatch = randperm(t, 2); % 隨機選擇兩個不同的位置
        dispatch_times1([pos_dispatch(1), pos_dispatch(2)]) = dispatch_times1([pos_dispatch(2), pos_dispatch(1)]); 
    end

    % 返回新的突變後的染色體和派遣時間
    Y = A2; % 返回突變後的染色體
    dispatch_times_new2 = dispatch_times1; % 返回突變後的派遣時間

end