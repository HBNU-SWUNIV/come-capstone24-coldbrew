% 사용자 좌표 및 파라미터 초기화
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

% 하나의 figure에 모든 경로 시각화 (크기 설정 포함)
figure('Position', [100, 100, 800, 800]);
hold on;
xlabel('X (m)');
ylabel('Y (m)');
grid on;
xlim([0 100]);
ylim([0 100]);
title('Combined Flight Paths (Birdview)');

% 사용자 위치 표시
user_plot = plot(user_x, user_y, 'bo', 'MarkerSize', 10, 'DisplayName', 'Users');

% 사용자 번호 표시
for i = 1:N_users
    text(user_x(i), user_y(i), sprintf('%d', i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 10, 'Color', 'blue');
end

%% Case 1: 정사각형 비행 경로
side_length = 12.5;
drone_pos = start_point;
steps = 100;
x_path = linspace(start_point(1), 40, steps);
y_path = linspace(start_point(2), 30, steps);

% 초기 경로 그리기
case1_plot = plot(x_path, y_path, 'r-', 'LineWidth', 2, 'DisplayName', 'Square Path (Case 1)');

% 정사각형 경로 그리기
drone_pos = [40, 30, z_height];
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
    plot([prev_drone_pos(1), drone_pos(1)], [prev_drone_pos(2), drone_pos(2)], 'r-', 'LineWidth', 2);
    prev_drone_pos = drone_pos;
end

%% Case 2: 원형 비행 경로
final_point_case2 = [44, 33, z_height];
center_case2 = [49.09, 36.82, z_height];
r_case2 = 40 / (2 * pi);
theta_0_case2 = atan2(final_point_case2(2) - center_case2(2), final_point_case2(1) - center_case2(1));

x_path = linspace(start_point(1), final_point_case2(1), steps);
y_path = linspace(start_point(2), final_point_case2(2), steps);

case2_plot = plot(x_path, y_path, 'g-', 'LineWidth', 2, 'DisplayName', 'Large Circular Path (Case 2)');

prev_drone_pos = final_point_case2;
for t = linspace(comm_time, flight_time, (flight_time - comm_time) / comm_interval + 1)
    theta = theta_0_case2 + 2 * pi * (t - comm_time) / (flight_time - comm_time);
    drone_pos(1) = center_case2(1) + r_case2 * cos(theta);
    drone_pos(2) = center_case2(2) + r_case2 * sin(theta);
    plot([prev_drone_pos(1), drone_pos(1)], [prev_drone_pos(2), drone_pos(2)], 'g-', 'LineWidth', 2);
    prev_drone_pos = drone_pos;
end

%% Case 3: 더 작은 원형 비행 경로
final_point_case3 = [48, 36, z_height];
center_case3 = [51.82, 38.86, z_height];
r_case3 = 30 / (2 * pi);
theta_0_case3 = atan2(final_point_case3(2) - center_case3(2), final_point_case3(1) - center_case3(1));

x_path_case3 = linspace(start_point(1), final_point_case3(1), steps);
y_path_case3 = linspace(start_point(2), final_point_case3(2), steps);

case3_plot = plot(x_path_case3, y_path_case3, 'b-', 'LineWidth', 2, 'DisplayName', 'Small Circular Path (Case 3)');

prev_drone_pos = final_point_case3;
for t = linspace(comm_time, flight_time, (flight_time - comm_time) / comm_interval + 1)
    theta = theta_0_case3 + 2 * pi * (t - comm_time) / (flight_time - comm_time);
    drone_pos(1) = center_case3(1) + r_case3 * cos(theta);
    drone_pos(2) = center_case3(2) + r_case3 * sin(theta);
    plot([prev_drone_pos(1), drone_pos(1)], [prev_drone_pos(2), drone_pos(2)], 'b-', 'LineWidth', 2);
    prev_drone_pos = drone_pos;
end

%% Case 4: 호버링 후 복귀 경로
final_point_case4 = [48, 36, z_height]; % 호버링 위치
x_path_case4 = linspace(start_point(1), final_point_case4(1), steps);
y_path_case4 = linspace(start_point(2), final_point_case4(2), steps);

case4_plot = plot(x_path_case4, y_path_case4, 'm-', 'LineWidth', 2, 'DisplayName', 'Hovering Path (Case 4)');

% 호버링 (드론이 고정된 위치에서 머무름)
pause(hover_time);

% 복귀 경로 (48,36)에서 (0,0)으로 복귀
x_back_case4 = linspace(final_point_case4(1), start_point(1), steps);
y_back_case4 = linspace(final_point_case4(2), start_point(2), steps);

for i = 1:steps
    plot([x_back_case4(max(1, i-1)) x_back_case4(i)], [y_back_case4(max(1, i-1)) y_back_case4(i)], 'm-', 'LineWidth', 2);
end

hold off;

% 범례 설정 (경로와 색상이 일치하도록 설정, 우측 상단에 배치)
legend([user_plot, case1_plot, case2_plot, case3_plot, case4_plot], ...
    'Users', 'Square Path (Case 1)', 'Large Circular Path (Case 2)', 'Small Circular Path (Case 3)', 'Hovering Path (Case 4)', ...
    'Location', 'northeast');
