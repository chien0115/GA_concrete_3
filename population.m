function [Y, dispatch_times] = population(n, demand_trips, num_trucks, time_windows,time)
% n: 染色體數量 (族群大小)
% demand_trips: 各工地需求車次的陣列
% num_trucks: 車輛數量
% time_windows: 每個工地的時間窗 [最早派遣時間, 最晚派遣時間]

num_sites = length(demand_trips); % 工地數量
total_trips = sum(demand_trips); % 總需求車次

% 初始化族群矩陣
Y = zeros(n, total_trips); % 每個染色體僅包含工地之間的去程
dispatch_times = zeros(n, num_trucks); % 儲存每個染色體的派遣時間

for i = 1:n
    % 生成工地的派遣順序
    dispatch_order = [];
    random_values = [];
    for j = 1:num_sites
        % 將工地 j 需求的次數添加到派遣順序中
        dispatch_order = [dispatch_order, repmat(j, 1, demand_trips(j))]; %dispatch_order = [1, 1, 2, 2, 2, 3]

        % 為工地 j 的每次派遣生成隨機值
        random_values = [random_values, rand(1, demand_trips(j))]; %random_values = [0.5, 0.7, 0.2, 0.8, 0.6, 0.4]
    end

    % 將隨機值和派遣順序結合
    dispatch_random_pairs = [dispatch_order; random_values]';%dispatch_random_pairs = [1, 0.5; 1, 0.7; 2, 0.2; 2, 0.8; 2, 0.6; 3, 0.4]

    % 根據隨機值由小到大排序
    sorted_pairs = sortrows(dispatch_random_pairs, 2);
    sorted_dispatch_order = sorted_pairs(:, 1)';

    % 將排序後的派遣順序轉換為染色體
    chromosome = sorted_dispatch_order;

    % 保存到族群矩陣
    Y(i, :) = chromosome;

    % 為每輛車生成派遣時間
    for j = 1:num_trucks
        % 隨機選擇一個工地
        site_idx = randi(num_sites);
        % 獲取工地的時間窗
        early_time = time_windows(site_idx, 1)-time(site_idx,1);
        time_range = time_windows(site_idx,2) - time_windows(site_idx,1);


        % 使用線性加權的隨機時間生成 (偏向早期)
        random_time = rand()^10; % 這裡使用平方來偏向小的值，即較早的時間
        dispatch_time = early_time + random_time * (time_range); % 將其轉換到具體時間範圍內

        % 將派遣時間四捨五入為整數
        dispatch_times(i, j) = round(dispatch_time);
    end

end
end