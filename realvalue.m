function [F, YY1] = realvalue(P, E, R)
    [x, y] = size(P); % 目前经历过 crossover、mutation 的 P
    YY1 = P; % 直接保存所有染色體
    F = zeros(x, 1); % 初始化適應度向量

    for i = 1:x
        F(i) = R - E(i);  % 計算實際適應度值
    end
end
