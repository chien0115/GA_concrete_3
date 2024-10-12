function E = evaluation(P, t, time_windows, num_sites, dispatch_times, work_time, time, max_interrupt_time,  demand_trips, penalty)
    [x1, y1] = size(P);  % 獲取染色體數量和每個染色體的位元數

    num_dispatch_order = y1;  % 派遣順序的部分
    H = zeros(1, x1);  % 初始化適應度值
    num_sites_with_factory = num_sites + 1;  % 包括工廠的總工地數

    for i = 1:x1  % 遍歷每個染色體
        truck_availability = zeros(1, t);  % 追踪每台卡車何時可以再次使用
        
        % 初始化懲罰值
        penalty_side_time = 0;  % 每個工地的懲罰時間
        penalty_truck_time = 0;  % 卡車等待懲罰時間
        
        % 取出派遣時間部分
        dispatch_times_for_chromosome(i,:) = dispatch_times(i,:);
        
        % 取出派遣順序部分(y1->工地派遣順序)
        dispatch_order_for_chromosome = P(i, 1:num_dispatch_order);

        % 初始化工地的派遣信息
        arrival_time = zeros(num_sites, num_dispatch_order);
        start_time = zeros(num_sites, num_dispatch_order);
        finish_time = zeros(num_sites, num_dispatch_order);

        previous_site_id = 0;  % 初始化上一個工地的 site_id

        for k = 1:num_dispatch_order
            site_id = dispatch_order_for_chromosome(k);

            % 檢查 site_id 是否有效
            if site_id < 1 || site_id > num_sites_with_factory
                error('site_id 超出有效範圍: %d', site_id);
            end

            % 計算派遣時間
            if k <= t
                truck_id = k;
                % 使用染色體中對應的派遣時間
                actual_dispatch_time = dispatch_times_for_chromosome(k);
            else
                % 從可用的卡車中選擇最早可用的卡車
                [next_available_time, truck_id] = min(truck_availability);
                actual_dispatch_time = max(next_available_time, dispatch_times_for_chromosome(mod(k-1, t) + 1));
            end

            if site_id < 1 || site_id > num_sites
                % 處理工廠的情況
                % 計算到達工地的時間
                work_start_time_site = max(actual_dispatch_time + time(previous_site_id, 1), time_windows(site_id, 1));
                finish_time_site = work_start_time_site + work_time(previous_site_id);

                % 計算回到工廠的時間
                return_time = finish_time_site + time(previous_site_id, 2);

                % 更新卡車的可用時間 每次皆需要3分鐘裝新混凝土
                truck_availability(truck_id) = return_time+3;

                % 更新工廠的派遣信息
                return_time(site_id, k) = return_time;
            else
                % 處理工地的情況
                travel_to_site = time(site_id, 1);
                work_start_time_site = max(actual_dispatch_time + travel_to_site, time_windows(site_id, 1));
                finish_time_site = work_start_time_site + work_time(site_id);


                % 更新工地的派遣信息
                arrival_time(site_id, k) = actual_dispatch_time + travel_to_site;
                start_time(site_id, k) = work_start_time_site;
                finish_time(site_id, k) = finish_time_site;

                % 計算工地的中斷時間
                if length(finish_time(site_id, finish_time(site_id,:) > 0)) > 1
                    previous_finish_time = finish_time(site_id, k-1);
                    interruption_time = actual_dispatch_time + travel_to_site - previous_finish_time;

                    %超過容許中斷時間
                    if interruption_time > max_interrupt_time(site_id)
                        penalty_side_time = penalty_side_time + 1;
                    end
                end

                % 計算卡車的等待時間
                truck_waiting_time = work_start_time_site - (actual_dispatch_time + travel_to_site);
                if truck_waiting_time > 0
                    penalty_truck_time = penalty_truck_time + truck_waiting_time;
                end

                % 更新上一個工地的 site_id
                previous_site_id = site_id;
            end
        end

        % % 讓工地等
        % total_penalty_time_truck =sum(penalty_truck_time);
        % %讓卡車等
        % total_penalty_time_side=sum(penalty_side_time);

        % 計算總懲罰值（基於每小時的懲罰率）
        total_penalty = (penalty_side_time * penalty)-penalty_truck_time;

        % 計算適應度值（假設目標是最小化總懲罰值）
        H(i) = total_penalty;
    end

    E = H;  % 返回適應度值
end
