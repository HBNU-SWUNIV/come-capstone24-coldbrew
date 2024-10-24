% 총 반복 횟수 및 사용자 수 설정
num_users = 8; % 사용자 수

% 평균 및 총합 용량 저장할 변수 초기화
average_capacity_case1 = zeros(1, num_users);
average_capacity_case2 = zeros(1, num_users);
average_capacity_case3 = zeros(1, num_users);
average_capacity_case4 = zeros(1, num_users);

aggregate_capacity_case1 = zeros(1, num_users);
aggregate_capacity_case2 = zeros(1, num_users);
aggregate_capacity_case3 = zeros(1, num_users);
aggregate_capacity_case4 = zeros(1, num_users);

% 각 고정된 파일 이름의 CSV 파일을 읽어 저장
average_capacity_case1 = csvread('average_capacity_case1.csv');
average_capacity_case2 = csvread('average_capacity_case2.csv');
average_capacity_case3 = csvread('average_capacity_case3.csv');
average_capacity_case4 = csvread('average_capacity_case4.csv');

aggregate_capacity_case1 = csvread('aggregate_capacity_case1.csv');
aggregate_capacity_case2 = csvread('aggregate_capacity_case2.csv');
aggregate_capacity_case3 = csvread('aggregate_capacity_case3.csv');
aggregate_capacity_case4 = csvread('aggregate_capacity_case4.csv');

% 사용자별 평균 용량의 평균 계산 (단일 파일이므로 그대로 사용 가능)
avg_capacity_case1 = mean(average_capacity_case1, 1);
avg_capacity_case2 = mean(average_capacity_case2, 1);
avg_capacity_case3 = mean(average_capacity_case3, 1);
avg_capacity_case4 = mean(average_capacity_case4, 1);

% 사용자별 총 용량의 평균 계산
agg_capacity_case1 = mean(aggregate_capacity_case1, 1);
agg_capacity_case2 = mean(aggregate_capacity_case2, 1);
agg_capacity_case3 = mean(aggregate_capacity_case3, 1);
agg_capacity_case4 = mean(aggregate_capacity_case4, 1);

% 사용자별 평균 용량 그래프
figure;

subplot(2, 1, 1); % 첫 번째 subplot에 평균 용량 그래프 그리기
bar((1:num_users) - 0.3, avg_capacity_case1, 0.2, 'DisplayName', 'Case 1'); % X와 Y의 길이를 맞춤
hold on;
bar((1:num_users) - 0.1, avg_capacity_case2, 0.2, 'DisplayName', 'Case 2');
bar((1:num_users) + 0.1, avg_capacity_case3, 0.2, 'DisplayName', 'Case 3');
bar((1:num_users) + 0.3, avg_capacity_case4, 0.2, 'DisplayName', 'Case 4');
hold off;

xlabel('Users');
ylabel('Average Capacity (Mbps)');
title('Average Capacity per User');
legend('show', 'Location', 'northeastoutside'); % 범례를 그래프 밖에 표시
legend('FontSize', 8); % 범례의 글자 크기 축소
set(gca, 'LooseInset', get(gca, 'TightInset')); % 그래프가 플롯에 꽉 차도록 설정

% 사용자별 총 용량 그래프
subplot(2, 1, 2); % 두 번째 subplot에 총 용량 그래프 그리기
bar((1:num_users) - 0.3, agg_capacity_case1, 0.2, 'DisplayName', 'Case 1'); % X와 Y의 길이를 맞춤
hold on;
bar((1:num_users) - 0.1, agg_capacity_case2, 0.2, 'DisplayName', 'Case 2');
bar((1:num_users) + 0.1, agg_capacity_case3, 0.2, 'DisplayName', 'Case 3');
bar((1:num_users) + 0.3, agg_capacity_case4, 0.2, 'DisplayName', 'Case 4');
hold off;

xlabel('Users');
ylabel('Aggregate Capacity (Mbps)');
title('Aggregate Capacity per User');
legend('show', 'Location', 'northeastoutside'); % 범례를 그래프 밖에 표시
legend('FontSize', 8); % 범례의 글자 크기 축소
set(gca, 'LooseInset', get(gca, 'TightInset')); % 그래프가 플롯에 꽉 차도록 설정

% 평균 용량과 총 용량 데이터를 CSV 파일로 저장
csv_data = [avg_capacity_case1', avg_capacity_case2', avg_capacity_case3', avg_capacity_case4', ...
            agg_capacity_case1', agg_capacity_case2', agg_capacity_case3', agg_capacity_case4'];
header = {'Avg_Capacity_Case1', 'Avg_Capacity_Case2', 'Avg_Capacity_Case3', 'Avg_Capacity_Case4', ...
          'Agg_Capacity_Case1', 'Agg_Capacity_Case2', 'Agg_Capacity_Case3', 'Agg_Capacity_Case4'};
csv_filename = '1000times_simulate.csv';

% CSV 파일로 저장
fid = fopen(csv_filename, 'w');
fprintf(fid, '%s,', header{:});
fprintf(fid, '\n');
fclose(fid);
dlmwrite(csv_filename, csv_data, '-append');

disp(['CSV 파일이 성공적으로 저장되었습니다: ' csv_filename]);
