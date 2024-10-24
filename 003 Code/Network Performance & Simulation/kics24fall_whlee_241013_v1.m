% 파라미터 설정
v = 5; % 드론 속도 (m/s)
flight_time = 30; % 드론 총 비행 시간 (초)
comm_time = 10; % 비행 후 통신 시작 시간 (초)
user_height = 2;
z_height = 15; % 고정된 높이 (m)
N_users = 8; % 사용자 수
comm_interval = 0.01; % 10ms 마다 통신
start_point = [0, 0, z_height]; % 드론 출발 지점

% 사용자 랜덤 좌표 생성 (40,30) ~ (60,60) 사이
user_x = 40 + (60-40) * rand(1, N_users);
user_y = 30 + (60-30) * rand(1, N_users);
user_z = user_height * ones(1, N_users);

% SNR 설정 및 변환 함수
SNRdB = 10; % SNR = 10 dB (Assumption)
SNR_linear = 10^(SNRdB / 10);

B = 1; % 사용자당 대역폭: 1 MHz

%통신 성능 계산 함수 (SNR -> Capacity)
calculate_capacity = @(h, distance) log2(1 + SNR_linear * abs(h).^2 ./ distance.^2); % SNR 기반 용량 계산

%% Case 1: 정사각형 비행 경로 및 성능 계산
figure(1); % Case 1 비행 경로 시각화
plot3(user_x, user_y, user_z, 'bo', 'MarkerSize', 10, 'DisplayName', 'Users');
hold on;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
grid on;
xlim([0 100]);
ylim([0 100]);
zlim([0 30]);
view(3);
title('Case 1: Square Flight Path');

% 사용자 번호 표시 (1부터 8까지)
for i = 1:N_users
    text(user_x(i), user_y(i), user_z(i), sprintf('%d', i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 10, 'Color', 'blue');
end

% 비행 경로 및 성능 계산
side_length = 12.5;
distances_case1 = [];
capacities_case1 = [];
drone_pos = start_point;
plot3(drone_pos(1), drone_pos(2), drone_pos(3), 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');
pause(0.5);

% (0,0)에서 (40,30,15)까지 천천히 이동
steps = 100;
x_path = linspace(start_point(1), 40, steps);
y_path = linspace(start_point(2), 30, steps);
z_path = linspace(start_point(3), z_height, steps);

for i = 1:steps
    plot3([x_path(max(1, i-1)) x_path(i)], [y_path(max(1, i-1)) y_path(i)], [z_path(max(1, i-1)) z_path(i)], 'r-', 'LineWidth', 2);
    plot3(x_path(i), y_path(i), z_path(i), 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
    pause(0.01);
end

drone_pos = [40, 30, z_height];
pause(1);

% 정사각형 경로 및 성능 계산
prev_drone_pos = drone_pos;
for t = linspace(comm_time, flight_time, (flight_time-comm_time)/comm_interval + 1)
    if mod(t, 4*side_length/v) < side_length/v
        drone_pos(1) = 40 + v * mod(t, side_length/v);
        drone_pos(2) = 30;
    elseif mod(t, 4*side_length/v) < 2*side_length/v
        drone_pos(1) = 40 + side_length;
        drone_pos(2) = 30 + v * mod(t, side_length/v);
    elseif mod(t, 4*side_length/v) < 3*side_length/v
        drone_pos(1) = 40 + side_length - v * mod(t, side_length/v);
        drone_pos(2) = 30 + side_length;
    else
        drone_pos(1) = 40;
        drone_pos(2) = 30 + side_length - v * mod(t, side_length/v);
    end

    plot3([prev_drone_pos(1), drone_pos(1)], [prev_drone_pos(2), drone_pos(2)], [prev_drone_pos(3), drone_pos(3)], 'r-', 'LineWidth', 2);
    plot3(drone_pos(1), drone_pos(2), drone_pos(3), 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');

    % 거리 및 통신 성능 계산
    distances = sqrt((drone_pos(1) - user_x).^2 + (drone_pos(2) - user_y).^2 + (z_height - user_z).^2);
    distances_case1 = [distances_case1; distances];

    % Fading Channel 상태 생성 및 용량 계산
    h = 1/sqrt(2) * (randn(1, N_users) + 1j * randn(1, N_users));
    capacities_case1 = [capacities_case1; calculate_capacity(h, distances)];

    prev_drone_pos = drone_pos;
    pause(0.01);
end

% 평균 용량 계산
average_capacity_per_user = mean(capacities_case1 / (10 * 10^-3), 1); % Mbps 단위

% 성능 결과 시각화 (Case 1)
figure(12);
subplot(2,1,1);
plot(linspace(0, flight_time, size(distances_case1,1)), distances_case1);
title('Case 1: Distance over Time (Square Flight)');
xlabel('Time (s)');
ylabel('Distance (m)');

% 통신 구간 (11~20초) 이외의 구간은 0으로 처리
capacities_case1_full = zeros(size(capacities_case1));
time_indices_case1 = find(linspace(0, flight_time, size(capacities_case1,1)) >= 11 & linspace(0, flight_time, size(capacities_case1,1)) <= 20);
capacities_case1_full(time_indices_case1, :) = capacities_case1(time_indices_case1, :);

% 평균 용량 계산 (통신이 실제로 일어난 구간만)
average_capacity_with_communication = mean(capacities_case1_full(capacities_case1_full~=0) / (10*10^-3), 1); % Mbps

% 시각화: 용량 변화 (시간에 따른)
subplot(2,1,2);
plot(linspace(0, flight_time, size(capacities_case1_full,1)), capacities_case1_full, 'r-');
title('Case 1: Capacity over Time (Square Flight)');
xlabel('Time (s)');
ylabel('Capacity (Mbps)');

%% 사용자 성능 시각화 (Average vs Aggregate)
users = categorical({'User 1', 'User 2', 'User 3', 'User 4', 'User 5', 'User 6', 'User 7', 'User 8'});
average_capacity = mean(capacities_case1_full, 1);
aggregate_capacity = sum(capacities_case1_full, 1);

figure(13);

% Average Capacity plot
subplot(2,1,1);
bar(average_capacity);
title('Average Capacity per User');
xlabel('Users');
ylabel('Average Capacity (Mbps)');
ylim([0, max(average_capacity) * 1.2]); % y축 크기 조정

% 막대 위에 평균 용량 값을 표시 (막대보다 위에 배치)
for i = 1:N_users
    text(i, average_capacity(i) + max(average_capacity)*0.05, sprintf('%.2f', average_capacity(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10, 'Color', 'black');
end

% Aggregate Capacity plot
subplot(2,1,2);
bar(aggregate_capacity);
title('Aggregate Capacity per User');
xlabel('Users');
ylabel('Aggregate Capacity (Mbps)');
ylim([0, max(aggregate_capacity) * 1.2]); % y축 크기 조정

% 막대 위에 총합 용량 값을 표시 (막대보다 위에 배치)
for i = 1:N_users
    text(i, aggregate_capacity(i) + max(aggregate_capacity)*0.05, sprintf('%.2f', aggregate_capacity(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10, 'Color', 'black');
end



%% Case 2: 원형 비행 경로 및 성능 계산 (한 붓 그리기)
% 드론이 원형 비행을 시작하는 지점과 원의 중심 좌표 정의
final_point_case2 = [44, 33, z_height];  % 드론이 원형 비행을 시작하는 지점
center_case2 = [49.09, 36.82, z_height];  % 원의 중심 좌표

figure(21); % Case 2 비행 경로
distances_case2 = [];  % 빈 배열로 초기화
capacities_case2 = []; % 용량도 빈 배열로 초기화

plot3(user_x, user_y, user_z, 'bo', 'MarkerSize', 10, 'DisplayName', 'Users');
hold on;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
grid on;
xlim([0 120]);
ylim([-20 120]);
zlim([0 30]);
view(3);
title('Case 2: Circular Flight Path');

% 사용자 번호 표시 (1부터 8까지, Case 1과 동일한 방식)
for i = 1:N_users
    text(user_x(i), user_y(i), user_z(i), sprintf('%d', i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 10, 'Color', 'blue');
end

% (0,0)에서 (44,33,15)까지 이동
steps = 100;
x_path = linspace(start_point(1), final_point_case2(1), steps);
y_path = linspace(start_point(2), final_point_case2(2), steps);
z_path = linspace(start_point(3), final_point_case2(3), steps);

for i = 1:steps
    plot3([x_path(max(1, i-1)) x_path(i)], [y_path(max(1, i-1)) y_path(i)], [z_path(max(1, i-1)) z_path(i)], 'r-', 'LineWidth', 2);
    plot3(x_path(i), y_path(i), z_path(i), 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
    pause(0.01);
end

drone_pos = final_point_case2;

% 원의 반지름 설정 (40m 원주)
r_case2 = 40 / (2 * pi); % 원주가 40m인 경우 반지름 계산

% 원형 비행 시작 각도를 (44,33)에서 시작하도록 설정
theta_0_case2 = atan2(final_point_case2(2) - center_case2(2), final_point_case2(1) - center_case2(1));

% theta_steps 설정 (한 바퀴 돌기 위한 각도 설정)
theta_steps_case2 = linspace(theta_0_case2, theta_0_case2 + 2*pi, 100); 

prev_drone_pos = final_point_case2; % 원형 비행 전에 (44,33)에서 출발

for t = linspace(comm_time, flight_time, (flight_time - comm_time) / comm_interval + 1)
    theta = theta_0_case2 + 2 * pi * (t - comm_time) / (flight_time - comm_time);

    % 드론의 새로운 위치는 중심을 기준으로 이동
    drone_pos(1) = center_case2(1) + r_case2 * cos(theta); % 중심 (49.09, 36.82) 기준 x 좌표
    drone_pos(2) = center_case2(2) + r_case2 * sin(theta); % 중심 (49.09, 36.82) 기준 y 좌표

    plot3([prev_drone_pos(1), drone_pos(1)], [prev_drone_pos(2), drone_pos(2)], [z_height z_height], 'r-', 'LineWidth', 2);
    plot3(drone_pos(1), drone_pos(2), z_height, 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');

    % 이전 위치를 현재 위치로 업데이트
    prev_drone_pos = drone_pos;

    % 거리 계산 및 저장
    distances = sqrt((drone_pos(1) - user_x).^2 + (drone_pos(2) - user_y).^2 + (z_height - user_z).^2);
    distances_case2 = [distances_case2; distances];

    % 통신 성능 계산
    h = 1/sqrt(2)*(randn(1, N_users) + 1j*randn(1, N_users)); % Fading channel
    capacities_case2 = [capacities_case2; calculate_capacity(h, distances)];

    pause(0.01);
end

% 원형 비행 후 (44,33)으로 복귀, 이후 (0,0)으로 복귀
steps_back = 100;
x_back_to_0 = linspace(final_point_case2(1), start_point(1), steps_back);
y_back_to_0 = linspace(final_point_case2(2), start_point(2), steps_back);

for i = 1:steps_back
    plot3([x_back_to_0(max(1, i-1)) x_back_to_0(i)], [y_back_to_0(max(1, i-1)) y_back_to_0(i)], [z_height z_height], 'r-', 'LineWidth', 2);
    plot3(x_back_to_0(i), y_back_to_0(i), z_height, 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
    pause(0.01);
end

%%%%%%%%%%%%%%% Average Capacity per User (during actual communications) %%%%%%%%%%%%%%%
mean(capacities_case2 / (10*10^-3), 1) % Unit: Mbps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 성능 결과 시각화 (Case 2)
figure(22);
subplot(2,1,1);
plot(linspace(0, flight_time, size(distances_case2,1)), distances_case2);
title('Case 2: Distance over Time (Circular Flight)');
xlabel('Time (s)');
ylabel('Distance (m)');

% Case 2 통신 구간 설정 (12~19초) 이외의 구간은 0으로 처리
capacities_case2_full = zeros(size(capacities_case2));
time_indices_case2 = find(linspace(0, flight_time, size(capacities_case2,1)) >= 12 & linspace(0, flight_time, size(capacities_case2,1)) <= 19);
capacities_case2_full(time_indices_case2, :) = capacities_case2(time_indices_case2, :);

subplot(2,1,2);
plot(linspace(0, flight_time, size(capacities_case2_full,1)), capacities_case2_full, 'r-');
title('Case 2: Capacity over Time (Circular Flight)');
xlabel('Time (s)');
ylabel('Capacity (Mbps)');

%% 사용자 성능 시각화 (Average vs Aggregate for Case 2)
users = categorical({'User 1', 'User 2', 'User 3', 'User 4', 'User 5', 'User 6', 'User 7', 'User 8'});
average_capacity = mean(capacities_case2_full, 1);
aggregate_capacity = sum(capacities_case2_full, 1);

figure(23);

% Average Capacity plot
subplot(2,1,1);
bar(average_capacity);
title('Average Capacity per User (Case 2)');
xlabel('Users');
ylabel('Average Capacity (Mbps)');
ylim([0, max(average_capacity) * 1.2]); % y축 크기 조정

% 막대 위에 평균 용량 값을 표시 (막대보다 위에 배치)
for i = 1:N_users
    text(i, average_capacity(i) + max(average_capacity)*0.05, sprintf('%.2f', average_capacity(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10, 'Color', 'black');
end

% Aggregate Capacity plot
subplot(2,1,2);
bar(aggregate_capacity);
title('Aggregate Capacity per User (Case 2)');
xlabel('Users');
ylabel('Aggregate Capacity (Mbps)');
ylim([0, max(aggregate_capacity) * 1.2]); % y축 크기 조정

% 막대 위에 총합 용량 값을 표시 (막대보다 위에 배치)
for i = 1:N_users
    text(i, aggregate_capacity(i) + max(aggregate_capacity)*0.05, sprintf('%.2f', aggregate_capacity(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10, 'Color', 'black');
end


%% Case 3: 더 작은 원형 비행 경로 및 성능 계산 (한 붓 그리기)
% 드론이 원형 비행을 시작하는 지점과 원의 중심 좌표 정의
final_point_case3 = [48, 36, z_height];  % 드론이 원형 비행을 시작하는 지점
center_case3 = [51.82, 38.86, z_height];  % 원의 중심 좌표

figure(31); % Case 3 비행 경로
distances_case3 = [];  % 빈 배열로 초기화
capacities_case3 = []; % 용량도 빈 배열로 초기화

plot3(user_x, user_y, user_z, 'bo', 'MarkerSize', 10, 'DisplayName', 'Users');
hold on;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
grid on;
xlim([0 120]);
ylim([0 120]);
zlim([0 30]);
view(3);
title('Case 3: Smaller Circular Flight Path');

% 사용자 번호 표시 (1부터 8까지, Case 1과 동일한 방식)
for i = 1:N_users
    text(user_x(i), user_y(i), user_z(i), sprintf('%d', i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 10, 'Color', 'blue');
end

% (0,0)에서 (48,36,15)까지 이동
steps = 100;
x_path_case3 = linspace(start_point(1), final_point_case3(1), steps);
y_path_case3 = linspace(start_point(2), final_point_case3(2), steps);
z_path_case3 = linspace(start_point(3), final_point_case3(3), steps);

for i = 1:steps
    plot3([x_path_case3(max(1, i-1)) x_path_case3(i)], [y_path_case3(max(1, i-1)) y_path_case3(i)], [z_path_case3(max(1, i-1)) z_path_case3(i)], 'r-', 'LineWidth', 2);
    plot3(x_path_case3(i), y_path_case3(i), z_path_case3(i), 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
    pause(0.01);
end

drone_pos = final_point_case3;

% 원의 반지름 설정
r_case3 = 30 / (2 * pi);  % 원주가 30m인 경우 반지름 계산

% 원형 비행 시작 각도를 (48,36)에서 시작하도록 설정
theta_0_case3 = atan2(final_point_case3(2) - center_case3(2), final_point_case3(1) - center_case3(1));

% theta_steps 설정 (한 바퀴 돌기 위한 각도 설정)
theta_steps_case3 = linspace(theta_0_case3, theta_0_case3 + 2*pi, 100); 

prev_drone_pos = final_point_case3; % 원형 비행 전에 (48,36)에서 출발

for t = linspace(comm_time, flight_time, (flight_time - comm_time) / comm_interval + 1)
    theta = theta_0_case3 + 2 * pi * (t - comm_time) / (flight_time - comm_time);

    % 드론의 새로운 위치는 중심을 기준으로 이동
    drone_pos(1) = center_case3(1) + r_case3 * cos(theta); % 중심 (51.82, 38.86) 기준 x 좌표
    drone_pos(2) = center_case3(2) + r_case3 * sin(theta); % 중심 (51.82, 38.86) 기준 y 좌표

    plot3([prev_drone_pos(1), drone_pos(1)], [prev_drone_pos(2), drone_pos(2)], [z_height z_height], 'r-', 'LineWidth', 2);
    plot3(drone_pos(1), drone_pos(2), z_height, 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');

    % 이전 위치를 현재 위치로 업데이트
    prev_drone_pos = drone_pos;

    % 거리 계산 및 저장
    distances = sqrt((drone_pos(1) - user_x).^2 + (drone_pos(2) - user_y).^2 + (z_height - user_z).^2);
    distances_case3 = [distances_case3; distances];

    % 통신 성능 계산
    h = 1/sqrt(2)*(randn(1, N_users) + 1j*randn(1, N_users)); % Fading channel
    capacities_case3 = [capacities_case3; calculate_capacity(h, distances)];

    pause(0.01);
end

% 원형 비행 후 (48,36)으로 복귀, 이후 (0,0)으로 복귀
steps_back_case3 = 100;
x_back_case3 = linspace(final_point_case3(1), start_point(1), steps_back_case3);
y_back_case3 = linspace(final_point_case3(2), start_point(2), steps_back_case3);

for i = 1:steps_back_case3
    plot3([x_back_case3(max(1, i-1)) x_back_case3(i)], [y_back_case3(max(1, i-1)) y_back_case3(i)], [z_height z_height], 'r-', 'LineWidth', 2);
    plot3(x_back_case3(i), y_back_case3(i), z_height, 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
    pause(0.01);
end

%%%%%%%%%%%%%%% Average Capacity per User (during actual communications) %%%%%%%%%%%%%%%
mean(capacities_case3 / (10*10^-3), 1) % Unit: Mbps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 성능 결과 시각화 (Case 3)
figure(32);

subplot(2,1,1);
plot(linspace(0, flight_time, size(distances_case3,1)), distances_case3); % 거리를 시간에 따라 기록
title('Case 3: Distance over Time (Smaller Circular Flight)');
xlabel('Time (s)');
ylabel('Distance (m)');

% Case 3 통신 구간 설정 (13~18초) 이외의 구간은 0으로 처리
capacities_case3_full = zeros(size(capacities_case3));
time_indices_case3 = find(linspace(0, flight_time, size(capacities_case3,1)) >= 13 & linspace(0, flight_time, size(capacities_case3,1)) <= 18);
capacities_case3_full(time_indices_case3, :) = capacities_case3(time_indices_case3, :);

subplot(2,1,2);
plot(linspace(0, flight_time, size(capacities_case3_full,1)), capacities_case3_full, 'r-');
title('Case 3: Capacity over Time (Smaller Circular Flight)');
xlabel('Time (s)');
ylabel('Capacity (Mbps)');

%% 사용자 성능 시각화 (Average vs Aggregate for Case 3)
users = categorical({'User 1', 'User 2', 'User 3', 'User 4', 'User 5', 'User 6', 'User 7', 'User 8'});
average_capacity = mean(capacities_case3_full, 1);
aggregate_capacity = sum(capacities_case3_full, 1);

figure(33);

% Average Capacity plot
subplot(2,1,1);
bar(average_capacity);
title('Average Capacity per User (Case 3)');
xlabel('Users');
ylabel('Average Capacity (Mbps)');
ylim([0, max(average_capacity) * 1.2]); % y축 크기 조정

% 막대 위에 평균 용량 값을 표시 (막대보다 위에 배치)
for i = 1:N_users
    text(i, average_capacity(i) + max(average_capacity)*0.05, sprintf('%.2f', average_capacity(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10, 'Color', 'black');
end

% Aggregate Capacity plot
subplot(2,1,2);
bar(aggregate_capacity);
title('Aggregate Capacity per User (Case 3)');
xlabel('Users');
ylabel('Aggregate Capacity (Mbps)');
ylim([0, max(aggregate_capacity) * 1.2]); % y축 크기 조정

% 막대 위에 총합 용량 값을 표시 (막대보다 위에 배치)
for i = 1:N_users
    text(i, aggregate_capacity(i) + max(aggregate_capacity)*0.05, sprintf('%.2f', aggregate_capacity(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10, 'Color', 'black');
end



% Case 4: 호버링 상태로 6초 동안 통신 후 복귀
figure(41); % Case 4 비행 경로
distances_case4 = [];  % 거리 기록 배열 초기화
capacities_case4 = []; % 용량 기록 배열 초기화

% 사용자 위치 및 번호 표시 (1부터 8까지, Case 1과 동일한 방식)
plot3(user_x, user_y, user_z, 'bo', 'MarkerSize', 10, 'DisplayName', 'Users');
hold on;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
grid on;
xlim([0 120]);
ylim([0 120]);
zlim([0 30]);
view(3);
title('Case 4: Hovering for 6 seconds');

% 사용자 번호 표시
for i = 1:N_users
    text(user_x(i), user_y(i), user_z(i), sprintf('%d', i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 10, 'Color', 'blue');
end

% (0,0)에서 (48,36,15)까지 이동 (거리 계산 포함)
steps = 100;
x_path_case4 = linspace(start_point(1), final_point_case3(1), steps);
y_path_case4 = linspace(start_point(2), final_point_case3(2), steps);
z_path_case4 = linspace(start_point(3), final_point_case3(3), steps);

% 드론이 목표 지점까지 이동하는 동안 거리 계산 및 시각화
for i = 1:steps
    % 현재 드론 위치 업데이트
    drone_pos(1) = x_path_case4(i);
    drone_pos(2) = y_path_case4(i);
    drone_pos(3) = z_path_case4(i);

    % 거리 계산
    distances = sqrt((drone_pos(1) - user_x).^2 + (drone_pos(2) - user_y).^2 + (drone_pos(3) - user_z).^2);
    distances_case4 = [distances_case4; distances]; % 거리 기록

    % 비행 경로 시각화
    plot3([x_path_case4(max(1, i-1)) x_path_case4(i)], [y_path_case4(max(1, i-1)) y_path_case4(i)], [z_path_case4(max(1, i-1)) z_path_case4(i)], 'r-', 'LineWidth', 2);
    plot3(x_path_case4(i), y_path_case4(i), z_path_case4(i), 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
    pause(0.01);
end

% 6초 동안 호버링하면서 통신 (48,36,15)
hover_time = 6; % 호버링 시간 (초)
time_steps_hover = linspace(0, hover_time, hover_time / comm_interval);
hover_pos = final_point_case3; % 호버링 위치는 (48,36,15)

% 호버링 동안 거리 계산 및 통신 성능 계산
for t = time_steps_hover
    % 거리 계산 (호버링 동안 위치는 고정됨)
    distances = sqrt((hover_pos(1) - user_x).^2 + (hover_pos(2) - user_y).^2 + (z_height - user_z).^2);
    distances_case4 = [distances_case4; distances];

    % 통신 성능 계산 (Fading 채널 상태 생성)
    h = 1/sqrt(2)*(randn(1, N_users) + 1j*randn(1, N_users)); % Fading channel
    capacities_case4 = [capacities_case4; calculate_capacity(h, distances)];

    pause(0.01);
end

% 호버링 후 (48,36)에서 출발지점 (0,0)으로 복귀
steps_back_case4 = 100;
x_back_case4 = linspace(final_point_case3(1), start_point(1), steps_back_case4);
y_back_case4 = linspace(final_point_case3(2), start_point(2), steps_back_case4);

% 드론이 다시 출발 지점으로 복귀하는 동안 거리 계산 및 시각화
for i = 1:steps_back_case4
    % 현재 드론 위치 업데이트
    drone_pos(1) = x_back_case4(i);
    drone_pos(2) = y_back_case4(i);
    drone_pos(3) = z_height;

    % 거리 계산 및 기록
    distances = sqrt((drone_pos(1) - user_x).^2 + (drone_pos(2) - user_y).^2 + (drone_pos(3) - user_z).^2);
    distances_case4 = [distances_case4; distances];

    % 비행 경로 시각화
    plot3([x_back_case4(max(1, i-1)) x_back_case4(i)], [y_back_case4(max(1, i-1)) y_back_case4(i)], [z_height z_height], 'r-', 'LineWidth', 2);
    plot3(x_back_case4(i), y_back_case4(i), z_height, 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
    pause(0.01);
end

%%%%%%%%%%%%%% Average Capacity per User (during actual communications) %%%%%%%%%%%%%%%
mean(capacities_case4 / (10*10^-3), 1) % Unit: Mbps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 성능 결과 시각화 (Case 4)
figure(42);

% 거리 시각화
subplot(2,1,1);
plot(linspace(0, flight_time, size(distances_case4,1)), distances_case4); % 거리를 시간에 따라 기록
title('Case 4: Distance over Time (Hovering)');
xlabel('Time (s)');
ylabel('Distance (m)');

% 통신 구간 설정 (13~18초) 이외의 구간은 0으로 처리
capacities_case4_full = zeros(size(capacities_case4));
time_indices_case4 = find(linspace(0, flight_time, size(capacities_case4,1)) >= 13 & linspace(0, flight_time, size(capacities_case4,1)) <= 18);
capacities_case4_full(time_indices_case4, :) = capacities_case4(time_indices_case4, :);

% 용량 시각화
subplot(2,1,2);
plot(linspace(0, flight_time, size(capacities_case4_full,1)), capacities_case4_full, 'r-');
title('Case 4: Capacity over Time (Hovering)');
xlabel('Time (s)');
ylabel('Capacity (Mbps)');

% 사용자 성능 시각화 (Average vs Aggregate for Case 4)
users = categorical({'User 1', 'User 2', 'User 3', 'User 4', 'User 5', 'User 6', 'User 7', 'User 8'});
average_capacity = mean(capacities_case4_full, 1);
aggregate_capacity = sum(capacities_case4_full, 1);

figure(43);

% Average Capacity plot
subplot(2,1,1);
bar(average_capacity);
title('Average Capacity per User (Case 4)');
xlabel('Users');
ylabel('Average Capacity (Mbps)');
ylim([0, max(average_capacity) * 1.2]); % y축 크기 조정

% 막대 위에 평균 용량 값을 표시 (막대보다 위에 배치)
for i = 1:N_users
    text(i, average_capacity(i) + max(average_capacity)*0.05, sprintf('%.2f', average_capacity(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10, 'Color', 'black');
end

% Aggregate Capacity plot
subplot(2,1,2);
bar(aggregate_capacity);
title('Aggregate Capacity per User (Case 4)');
xlabel('Users');
ylabel('Aggregate Capacity (Mbps)');
ylim([0, max(aggregate_capacity) * 1.2]); % y축 크기 조정

% 막대 위에 총합 용량 값을 표시 (막대보다 위에 배치)
for i = 1:N_users
    text(i, aggregate_capacity(i) + max(aggregate_capacity)*0.05, sprintf('%.2f', aggregate_capacity(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10, 'Color', 'black');
end

