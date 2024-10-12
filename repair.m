function repaired_chromosome = repair(chromosome, demand_trips)
    num_sites = length(demand_trips);
    site_counts = zeros(1, num_sites);
    
    % 計算每個工地的訪問次數
    for i = 1:num_sites
        site_counts(i) = sum(chromosome == i);
    end
    
    % 修復過多派遣次數的工地
    for site = 1:num_sites
        %分配和允許的誤差值
        diff = site_counts(site) - demand_trips(site);
        
        while diff > 0
            % 找到該工地的所有位置
            site_positions = find(chromosome == site);

            % 找到需求不足的工地
            under_demand_sites = find(site_counts < demand_trips);

            % 如果沒有需求不足的工地，結束修復
            if isempty(under_demand_sites)
                break;
            end

            % 隨機選擇一個需求不足的工地
            new_site = under_demand_sites(randi(length(under_demand_sites)));
            
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

    % % 最後檢查並打破連續的相同工地
    % i = 1;
    % while i < length(chromosome)
    %     if chromosome(i) == chromosome(i+1)
    %         % 找到不同的工地來替換
    %         for j = i+2:length(chromosome)
    %             if chromosome(j) ~= chromosome(i)
    %                 % 交換位置
    %                 temp = chromosome(i+1);
    %                 chromosome(i+1) = chromosome(j);
    %                 chromosome(j) = temp;
    %                 break;
    %             end
    %         end
    %     end
    %     i = i + 1;
    % end

    % 返回修復後的染色體
    repaired_chromosome = chromosome;
end
