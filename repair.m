function repaired_chromosome = repair(chromosome, demand_trips)

%demand_trips[2,2,4,4,2]
num_sites = length(demand_trips);%長度5
site_counts = zeros(1, num_sites);

% 計算每個工地的訪問次數
for i = 1:num_sites%1-5
    site_counts(i) = sum(chromosome == i);%2 2 4 4 2
end

% 修復過多派遣次數的工地
for site = 1:num_sites
    %分配和允許的誤差值
    diff = site_counts(site) - demand_trips(site);

    %代表超過需要值
    while diff > 0
        % 找到該工地的所有位置
        site_positions = find(chromosome == site);

        % 找到需求不足的工地的位置
        under_demand_sites = find(site_counts < demand_trips);%site_counts = [2, 4, 1];  demand_trips = [3, 4, 2];
        % under_demand_sites =1     3

        % 如果沒有需求不足的工地，結束修復
        if isempty(under_demand_sites)
            break;
        end

        % 隨機選擇一個需求不足的工地
        new_site = under_demand_sites(randi(length(under_demand_sites))); %randi(需求不足的工地 數量)

        % 確保該工地有位置可替換
        if ~isempty(site_positions)
            % 隨機選擇一個該工地的位置進行替換
            idx_to_replace = site_positions(randi(length(site_positions)));
            chromosome(idx_to_replace) = new_site;

            % 更新計數
            site_counts(new_site) = site_counts(new_site) + 1;
            site_counts(site) = site_counts(site) - 1;
            diff = diff - 1;
        else
            break;
        end
    end
end

% 修復需求不足的工地
for site = 1:num_sites
    diff = site_counts(site) - demand_trips(site);

    while diff < 0
        % 找到需求過多的工地
        over_demand_sites = find(site_counts > demand_trips);

        % 如果沒有需求過多的工地，結束修復
        if isempty(over_demand_sites)
            break;
        end

        % 隨機選擇一個需求過多的工地
        new_site = over_demand_sites(randi(length(over_demand_sites)));

        % 找到一個不同於該工地的位置進行替換
        suitable_positions = find(chromosome ~= new_site);
        if isempty(suitable_positions)
            idx_to_replace = randi(length(chromosome));
        else
            idx_to_replace = suitable_positions(randi(length(suitable_positions)));
        end

        % 替換選中的位置
        chromosome(idx_to_replace) = site;

        % 更新計數
        site_counts(new_site) = site_counts(new_site) - 1;
        site_counts(site) = site_counts(site) + 1;
        diff = diff + 1;
    end
end



% 返回修復後的染色體
repaired_chromosome = chromosome;
end