function [Y, dispatch_times_new] = crossover(P, t, dispatch_times)
    [num_chromosomes, chromosome_length] = size(P);
    
    % 選擇兩個不同的父代染色體
    parent_indices = randperm(num_chromosomes, 2);
    
    % 選擇父染色體及其對應的派遣時間
    parent1 = P(parent_indices(1), :);
    parent2 = P(parent_indices(2), :);
    dispatch_times1 = dispatch_times(parent_indices(1), :);
    dispatch_times2 = dispatch_times(parent_indices(2), :);
    
    % 生成兩個隨機的染色體交配點
    crossover_points = sort(randi([1, chromosome_length - 1], 1, 2));
    point1 = crossover_points(1);
    point2 = crossover_points(2);
    dispatch_crossover_point = randi([1, t - 1]);
    
    % 染色體的雙點交配操作
    child1 = [parent1(1:point1), parent2(point1+1:point2), parent1(point2+1:end)];
    child2 = [parent2(1:point1), parent1(point1+1:point2), parent2(point2+1:end)];
    
    % 派遣時間的交配操作
    dispatch_times_child1 = [dispatch_times1(1:dispatch_crossover_point), dispatch_times2(dispatch_crossover_point+1:end)];
    dispatch_times_child2 = [dispatch_times2(1:dispatch_crossover_point), dispatch_times1(dispatch_crossover_point+1:end)];
    
    % 將新染色體和派遣時間存入結果
    Y = [child1; child2];
    dispatch_times_new = [dispatch_times_child1; dispatch_times_child2];
    
    % 可選：顯示結果以便除錯
    % disp('Chromosomes after Crossover:');
    % disp(Y);
    % disp('Dispatch Times after Crossover:');
    % disp(dispatch_times_new);
end