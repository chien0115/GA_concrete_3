function [E,all_dispatch_times] = evaluation(P, t, time_windows, num_sites, dispatch_times, work_time, time, max_interrupt_time, penalty)
[x1, y1] = size(P);  % 獲取染色體數量和每個染色體的位元數
num_dispatch_order = y1;  % 派遣順序的大小
H = zeros(1, x1);  % 初始化適應度值
all_dispatch_times = zeros(x1, num_sites);

for i = 1:x1  % 遍歷每個染色體
    truck_availability = zeros(1, t);  % 追踪每台卡車何時可以再次使用
    penalty_side_time = 0;  % 每個工地的懲罰時間
    penalty_truck_time = 0;  % 卡車等待懲罰時間

    dispatch_times_for_chromosome = dispatch_times(i,:);%每行染色體的派遣時間(t個)
    dispatch_order_for_chromosome = P(i, :);%每個染色體派遣順序
    travel_to_site = zeros(num_sites, num_dispatch_order);%每個到的時間
    start_time = zeros(num_sites, num_dispatch_order);%每個開始時間
    finish_time_site = zeros(num_sites, num_dispatch_order);%每個結束時間


    for k = 1:num_dispatch_order %開始進入每個族群染色體
        site_id = dispatch_order_for_chromosome(k);

        if site_id < 1 || site_id > num_sites
            error('site_id 超出有效範圍: %d', site_id);
        end

        %設計工地派遣時間 開始被派遣
        if k <= t
            truck_id = k;
            actual_dispatch_time = dispatch_times_for_chromosome(k);
        else %派遣t台車後
            % 更新卡車的可用時間
            [next_available_time, truck_id] = min(truck_availability);
            actual_dispatch_time = max(next_available_time, dispatch_times_for_chromosome(mod(k-1, t) + 1));
        end



        % 到達工地，計算旅行時間和工作完成時間
        travel_to_site(i,k) = time(site_id, 1);  % 到工地的時間
        start_time(i,k) = max(actual_dispatch_time + travel_to_site(i,k), time_windows(site_id, 1));
        finish_time_site(i,k) = start_time(i,k) + work_time(site_id);


        % 判斷是否有前一次派遣的工作完成時間，並計算中斷時間
        if k > 1 && finish_time_site(i, k-1) > 0  % 確保有前一次的完成時間
            previous_finish_time = finish_time_site(i, k-1);  % 取得前一次派遣的完成時間
            interruption_time = start_time(i,k) - previous_finish_time;  % 計算中斷時間

            if interruption_time > max_interrupt_time(site_id)
                penalty_side_time = penalty_side_time + 1;  % 增加懲罰
            end
        end

        truck_waiting_time =start_time(i,k) - (actual_dispatch_time + travel_to_site(i,k));
        if truck_waiting_time > 0
            penalty_truck_time = penalty_truck_time + truck_waiting_time;
        end

        previous_site_id = site_id;

        % 更新卡車返回工廠的行程
        travel_back_to_factory = time(site_id, 2);  % 從工地返回工廠的時間
        truck_availability(truck_id) = finish_time_site(i,k)+travel_back_to_factory+3;
        % actual_dispatch_time = finish_time(site_id, k) + travel_back_to_factory;
        all_dispatch_times(i, k) = actual_dispatch_time;  % 保存派車回到工廠的時間
    end

    total_penalty = (penalty_side_time * penalty) + penalty_truck_time;  % 總懲罰值
    H(i) = total_penalty;  % 適應度值
end

E = H;  % 返回適應度值
end
