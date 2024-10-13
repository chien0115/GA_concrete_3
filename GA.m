clear all
close all
clc


% 參數設置
n = 200; % 初始種群大小
c = 50; % 需要進行交叉的染色體對數
m = 20; % 需要進行突變的染色體數
tg = 100; % 總代數
num_sites = 5; % 工地
% num_sites_with_factory = num_sites + 1; % 包括工廠的總工地數

t = 5; % 卡車數
s=20;%好的染色體
r=10;%number of chromosomes passing between runs每次運行之間傳遞的染色體數 比較佳的染色體
crossoverRate = 0.8; % 定義交配率
mutationRate = 0.2; % 突變率
max_generations_without_improvement = 1000000; % 設定多少代沒有變化認為收斂
tolerance = 0.0001; % 設定適應度變化的容忍值



%480->早上8點
time_windows = [480, 600;
    480, 600;
    510, 600;
    480, 600;
    480, 600;]; % 每個工地的時間窗(每個工地每天開始、結束時間)
% route = [1, 2, 3, 4, 5]; % 染色體示例：工廠到工地的路徑

time = [
    30, 25;  % 去程到工地 1 需要 30 分鐘，回程需要 25 分鐘
    25, 20;  % 去程到工地 2 需要 25 分鐘，回程需要 20 分鐘
    40, 30;  % 去程到工地 3 需要 40 分鐘，回程需要 30 分鐘
    15, 15;  % 去程到工地 4 需要 35 分鐘，回程需要 30 分鐘
    35, 30;% 去程到工地 5 需要 20 分鐘，回程需要 15 分鐘
    ];

% 定義各工地的參數
max_interrupt_time = [5, 5, 15,5,5]; % 工地最大容許中斷時間 (分鐘)
work_time = [20, 30, 25,10,35]; % 各工地施工時間 (分鐘)
demand_trips = [2,2,4,4,2]; % 各工地需求車次
penalty = 24*60;% 懲罰值


% start_time = [8*60, 8*60, 8*60+30]; % 各工地開始施工的時間 (以分鐘計算)
% travel_time_to = [30, 25, 40]; % 去程時間 (分鐘)
% travel_time_back = [25, 20, 30]; % 回程時間 (分鐘)
% penalty_site_value = 5; % 懲罰時間 (分鐘)




figure
title('Blue-Average      Red-Minimum');
xlabel('Generation')
ylabel('Objective Function Value')
hold on




[P,dispatch_times] = population(n, demand_trips, t, time_windows,time); % 初始化種群 P只包含派出順序 OK
for i = 1:tg
    % 初始化
    K = zeros(tg, 2); % 儲存適應度的矩陣



    % 評估操作 每個染色體的適應值 OK
    E = evaluation(P, t, time_windows, num_sites, dispatch_times, work_time, time, max_interrupt_time,  demand_trips, penalty); % 評估族群 P 中每個染色體的適應度

    L=max(E);

    % 選擇最好的染色體 目前設定選s個 OK

    [A, S, best_dispatch_times] = selection(P, E, s, dispatch_times,L);
    %P:選出來的染色體   S:適應值大小  best_dispatch_times:最好的派遣時間

    %現在A是最好的染色體     %S最好適應度
    B=best_dispatch_times;

    cr_num=0;
    dispatch_times_cross = [];

    % 初始化
    C = []; % 初始化 C 為空矩陣

    %把好的作交配、變異
    % 交配操作  目前剩280
    for j = 1:(n-s)
        if cr_num < n-s % 確保還有足夠的染色體進行交配
            rand_crossover = rand();
            if rand_crossover <= crossoverRate
                [C_temp, dispatch_times_cross_temp] = crossover(A, t, B);

                % 添加交配后的两个新染色体
                C = [C; C_temp(1, :)];
                C = [C; C_temp(2, :)];

                % 添加交配后的派遣时间
                dispatch_times_cross = [dispatch_times_cross; dispatch_times_cross_temp(1, :)];
                dispatch_times_cross = [dispatch_times_cross; dispatch_times_cross_temp(2, :)];

                cr_num = cr_num + 2; % 更新交配次數
            else
                % 如果沒有交配，保留原染色體，但需要確保不超出範圍
                if (2*j-1) <= size(P, 1) && (2*j) <= size(P, 1)
                    % 保留第 2*j-1 和 第 2*j 染色體
                    C = [C; P(2*j-1, :)];
                    dispatch_times_cross = [dispatch_times_cross; dispatch_times(2*j-1, :)];

                    C = [C; P(2*j, :)];
                    dispatch_times_cross = [dispatch_times_cross; dispatch_times(2*j, :)];

                    cr_num = cr_num + 2; % 更新交配次數
                end
            end
        end
    end

    [x1 y1]=size(C);
    dispatch_times_mutation = [];

    % 修復交配後的染色體
    for j = 1:x1
        C(j, :) = repair(C(j, :), demand_trips);
    end

    M = []; % 初始化 M 為空矩陣

    % 突變操作
    for k = 1:x1
        rand_mutation = rand();
        if rand_mutation <= mutationRate
            [M_temp, dispatch_times_mutation_temp] = mutation(C(k, :), t, dispatch_times_cross(k, :));
            % disp(['Mutation Result (M_temp): Size = ', num2str(size(M_temp))]);
            M = [M; M_temp];  % 添加突變後的染色體
            dispatch_times_mutation = [dispatch_times_mutation; dispatch_times_mutation_temp];  % 添加突變後的派遣時間
        else
            M = [M; C(k, :)];  % 只保留未突變的染色體
            dispatch_times_mutation = [dispatch_times_mutation; dispatch_times_cross(k, :)];  % 只保留未突變的派遣時間
        end
    end
    % disp(['Final Result (M): Size = ', num2str(size(M))]);


    % 統整(selection、crossover、mutation)
    P=[A;M];
    dispatch_times=[B;dispatch_times_mutation];



    %再次評估適應度 計算平均適應度最佳適應度
    E = evaluation(P, t, time_windows, num_sites, dispatch_times, work_time, time, max_interrupt_time,  demand_trips, penalty); % 評估族群 P 中每個染色體的適應度

    % 記錄適應度
    K(i, 1) = sum(E) / n; % 平均適應度
    K(i, 2) = min(E); % 最佳適應度

    % 畫圖
    plot(i,K(i, 1), 'b.');  % 畫出第i代的平均適應度
    hold on
    plot(i,K(i, 2), 'r.');  % 畫出第i代的最佳適應度
    drawnow
end


[minValue, index] = min(K(:, 2)); % 提取出最小適應度值

% 提取最佳適應度值和最優解
best_chromosome = P(index, :); % 提取基因部分
best_chromosome_dispatch_times=best_dispatch_times(index, :);


disp('Best Chromosome:');
disp(best_chromosome);

disp('Best Dispatch Times:');
disp(best_chromosome_dispatch_times);


%解碼最佳解為派車計劃
dispatch_plan = decode_chromosome(best_chromosome, best_chromosome_dispatch_times, num_sites, demand_trips, time_windows, work_time, time);

% 展示派車順序表
vehicle_ids = dispatch_plan(:, 1);
site_ids = dispatch_plan(:, 2);
plan_dispatch_times = dispatch_plan(:, 3);
actual_dispatch_times = dispatch_plan(:, 4);
travel_times_to = dispatch_plan(:, 5);
arrival_times = dispatch_plan(:, 6);
site_set_start_times = dispatch_plan(:, 7); % 新增的工作開始時間
work_start_times = dispatch_plan(:, 8); % 新增的工作開始時間
work_times = dispatch_plan(:, 9);
site_finish_times = dispatch_plan(:, 10);
travel_times_back = dispatch_plan(:, 11);
return_times = dispatch_plan(:, 12);
truck_waiting_times = dispatch_plan(:, 13);
site_waiting_times = dispatch_plan(:, 14);





% 將時間轉換為 HH:MM 格式
plan_dispatch_times_formatted = cellstr(arrayfun(@convert_minutes_to_time, plan_dispatch_times, 'UniformOutput', false));
actual_dispatch_times_formatted = cellstr(arrayfun(@convert_minutes_to_time, actual_dispatch_times, 'UniformOutput', false));
arrival_times_formatted = cellstr(arrayfun(@convert_minutes_to_time, arrival_times, 'UniformOutput', false));
return_times_formatted = cellstr(arrayfun(@convert_minutes_to_time, return_times, 'UniformOutput', false));
site_finish_times_formatted = cellstr(arrayfun(@convert_minutes_to_time, site_finish_times, 'UniformOutput', false));
truck_waiting_times_formatted = cellstr(arrayfun(@(x) sprintf('%d min', x), truck_waiting_times, 'UniformOutput', false));
site_waiting_times_formatted = cellstr(arrayfun(@(x) sprintf('%d min', x), site_waiting_times, 'UniformOutput', false));
site_set_start_times_formatted = cellstr(arrayfun(@convert_minutes_to_time, site_set_start_times, 'UniformOutput', false));
work_start_times_formatted = cellstr(arrayfun(@convert_minutes_to_time, work_start_times, 'UniformOutput', false)); % 新增工作開始時間格式化

% 創建派遣計劃表格數據
dispatch_data = table(vehicle_ids, site_ids, actual_dispatch_times_formatted, travel_times_to, arrival_times_formatted, site_set_start_times_formatted, work_start_times_formatted, work_times, site_finish_times_formatted, travel_times_back, return_times_formatted, truck_waiting_times_formatted, site_waiting_times_formatted, ...
    'VariableNames', {'VehicleID', 'SiteID', 'ActualDispatchTime', 'TravelTimeTo', 'ArrivalTime', 'SiteSetTime', 'WorkStartTime', 'WorkTime', 'SiteFinishTime', 'TravelTimeBack', 'ReturnTime', 'TruckWaitingTime', 'SiteWaitingTime'});



% 顯示表格
figure;
uitable('Data', table2cell(dispatch_data), 'ColumnName', dispatch_data.Properties.VariableNames, ...
    'RowName', [], 'Position', [20 20 800 400]);

% 解码函数
function plan = decode_chromosome(chromosome, dispatch_times, t, demand_trips, time_windows,  work_time, time)
fprintf('Chromosome:\n');
disp(chromosome);  % 或者你可以使用 disp 來簡單地顯示矩陣
total_trips = sum(demand_trips);
site_ids = zeros(total_trips, 1);
plan_dispatch_times = zeros(total_trips, 1);
actual_dispatch_times = zeros(total_trips, 1);
travel_times_to = zeros(total_trips, 1);
arrival_times = zeros(total_trips, 1);
site_set_start_times = zeros(total_trips, 1);
work_start_times = zeros(total_trips, 1);
work_times = zeros(total_trips, 1);
site_finish_times = zeros(total_trips, 1);
travel_times_back = zeros(total_trips, 1);
return_times = zeros(total_trips, 1);
truck_waiting_times = zeros(total_trips, 1);
site_waiting_times = zeros(total_trips, 1);

% 初始化每个工地的派遣信息
site_dispatch_info = zeros(total_trips, 5); % [site_id, truck_id, dispatch_time, arrival_time, work_start_time]

% 在循环外生成有序的 dispatch_times
% 生成 420 到 620 之间的随机时间，并进行排序
% plan_dispatch_time = sort(420 + randi([1, 200], total_trips, 1));

% 初始化卡车可用时间
truck_availability = zeros(t, 1); % 每个卡车的可用时间

for i = 1:total_trips  %目前14
    site_ids(i) = chromosome(1,i);        % 当前的工地ID
    site_id = site_ids(i);                % 当前工地

    % 获取各个时间参数
    travel_times_to(i) = time(site_id,1);
    travel_times_back(i) = time(site_id,2);
    site_set_start_times(i) = time_windows(site_id,1);
    work_times(i) = work_time(site_id);

    if i <= t
        % 初期卡车的派遣
        truck_id = i;
        actual_dispatch_times(i) = dispatch_times(i);  % 实际派遣时间等于计划时间
        arrival_times(i) = actual_dispatch_times(i) + travel_times_to(i);  % 到达时间
        work_start_times(i) = max(arrival_times(i), site_set_start_times(site_id));  % 工作开始时间
    else
        % 后续卡车的派遣
        [next_available_time, truck_id] = min(truck_availability);  % 下一个可用卡车及其可用时间
        actual_dispatch_times(i) = next_available_time;  % 计算实际派遣时间
        arrival_times(i) = actual_dispatch_times(i) + travel_times_to(i);  % 计算到达时间
    end

    % 检查之前是否有卡车在该工地工作
    previous_work_idx = find(site_ids(1:i-1) == site_ids(i), 1, 'last');  % 查找前一辆卡车的工作记录
    if isempty(previous_work_idx)
        % 如果这是该工地的第一台卡车
        work_start_times(i) = max(arrival_times(i), site_set_start_times(site_id));  % 工作开始时间为到达时间或工地的开始时间
    else
        % 如果已经有卡车到过该工地，设置当前卡车的工作开始时间为前一台卡车的完成时间
        work_start_times(i) = max(arrival_times(i), site_finish_times(previous_work_idx));  % 工作开始时间为到达时间或前一辆卡车的完成时间
    end

    % 提前计算工地完成时间和卡车返回时间
    site_finish_times(i) = work_start_times(i) + work_times(i);  % 工地的完成时间
    return_times(i) = site_finish_times(i) + travel_times_back(i);  % 卡车返回时间
    truck_availability(truck_id) = return_times(i);  % 更新卡车的可用时间

    % 计算等待时间
    if ~isempty(previous_work_idx)
        % 如果之前有车已经到过该工地，判断是卡车等待还是工地等待
        if arrival_times(i) < site_finish_times(previous_work_idx)
            truck_waiting_times(i) = site_finish_times(previous_work_idx) - arrival_times(i);
        elseif arrival_times(i) > site_finish_times(previous_work_idx)
            site_waiting_times(i) = arrival_times(i) - site_finish_times(previous_work_idx);
        end
    else
        % 第一次到该工地
        if arrival_times(i) < site_set_start_times(i)
            truck_waiting_times(i) = site_set_start_times(i) - arrival_times(i);
        else
            site_waiting_times(i) = arrival_times(i) - site_set_start_times(i);
        end
    end

    % 更新工地的调度信息
    idx = find(site_dispatch_info(:, 1) == site_id, 1, 'last') + 1;  % 找到该工地调度信息的最后一行
    if isempty(idx)
        idx = 1;
    end
    site_dispatch_info(idx, :) = [site_ids(i), truck_id, plan_dispatch_times(i), arrival_times(i), work_start_times(i)];

    % 打印调试信息
    fprintf('Trip %d: Site %d, Planned Dispatch: %f, Actual Dispatch: %f, Arrival: %f, Work Start: %f, Return: %f\n', ...
        i, site_ids(i), plan_dispatch_times(i), actual_dispatch_times(i), arrival_times(i), work_start_times(i), return_times(i));
end




vehicle_ids = (1:total_trips)';
plan = [vehicle_ids, site_ids, plan_dispatch_times, actual_dispatch_times, travel_times_to, arrival_times, site_set_start_times, work_start_times, work_times, site_finish_times, travel_times_back, return_times,truck_waiting_times, site_waiting_times];
end



% 分鐘轉換為 HH:MM 格式的函數
function time_str = convert_minutes_to_time(minutes)
hours = floor(minutes / 60);
mins = mod(minutes, 60);
time_str = sprintf('%02d:%02d', hours, mins);
end
