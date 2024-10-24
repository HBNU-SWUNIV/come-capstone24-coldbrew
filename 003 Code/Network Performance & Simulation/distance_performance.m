% 파라미터 설정
v = 5; % 드론 속도 (m/s)
flight_time = 30; % 드론 총 비행 시간 (초)
comm_interval = 0.01; % 통신 간격 (초)
user_height = 2;
z_height = 15; % 고정된 높이 (m)
N_users = 8; % 사용자 수
start_point = [0, 0, z_height]; % 드론 출발 지점
num_simulations = 1000; % 시뮬레이션 횟수

% 사용자 랜덤 좌표 생성 (40,30) ~ (60,60) 사이
user_x = 40 + (60-40) * rand(1, N_users);
user_y = 30 + (60-30) * rand(1, N_users);
user_z = user_height * ones(1, N_users);

% SNR 설정 및 변환 함수
SNRdB = 10; % SNR = 10 dB (Assumption)
SNR_linear = 10^(SNRdB / 10);

B = 1; % 사용자당 대역폭: 1 MHz

% 통신 성능 계산 함수 (SNR -> Capacity)
calculate_capacity = @(h, distance) log2(1 + SNR_linear * abs(h).^2 ./ distance.^2); % SNR 기반 용량 계산

% x축 (편도 거리) 설정
distances = 0:0.1:75; % 0부터 75까지 0.1씩 증가

% 모든 aggregate 성능을 저장할 배열 (평균값 저장)
avg_total_aggregate_capacity = zeros(size(distances));

for idx = 1:length(distances)
    d = distances(idx);
    total_capacity_per_simulation = zeros(1, num_simulations); % 각 시뮬레이션에서의 용량 저장
    
    % 1000회 시뮬레이션 반복
    for sim = 1:num_simulations
        % 통신 가능한 시간 계산
        travel_time = (2 * d) / v; % 왕복 이동 시간
        remaining_time = max(0, flight_time - travel_time); % 남은 통신 시간

        % 통신 시간이 0이면 성능도 0으로 설정
        if remaining_time == 0
            total_capacity_per_simulation(sim) = 0;
            continue;
        end
        
        % 원형 비행의 중심 좌표 설정
        center = [d * 0.8, d * 0.6, z_height]; % 빗변이 d인 직각삼각형 사용
        r = (remaining_time * v) / (2 * pi); % 원형 비행 반지름 계산

        % 원형 비행 경로 및 통신 성능 계산
        drone_pos = [center(1) + r, center(2), z_height];
        aggregate_capacity = 0;

        for t = 0:comm_interval:remaining_time
            theta = 2 * pi * (t / remaining_time);
            drone_pos(1) = center(1) + r * cos(theta);
            drone_pos(2) = center(2) + r * sin(theta);

            % 거리 계산 및 통신 성능 계산
            distances_to_users = sqrt((drone_pos(1) - user_x).^2 + (drone_pos(2) - user_y).^2 + (z_height - user_z).^2);
            h = 1/sqrt(2) * (randn(1, N_users) + 1j * randn(1, N_users));
            capacities = calculate_capacity(h, distances_to_users);
            aggregate_capacity = aggregate_capacity + sum(capacities) * comm_interval; % 누적 용량

        end
        total_capacity_per_simulation(sim) = aggregate_capacity; % 시뮬레이션별 총 용량 저장
    end
    
    % 1000회 시뮬레이션의 평균값 저장
    avg_total_aggregate_capacity(idx) = mean(total_capacity_per_simulation);
end

% 최고 성능과 그 좌표 찾기
[max_capacity, max_idx] = max(avg_total_aggregate_capacity);
best_d = distances(max_idx);

% 그래프 그리기
figure;
plot(distances, avg_total_aggregate_capacity, 'b-', 'LineWidth', 1.5);
hold on;
plot(best_d, max_capacity, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % 최고 성능 좌표에 빨간 점
title('Distance-Based Circular Flight Drone Communication Performance');
xlabel('One-way Distance (m)');
ylabel('Total Aggregate Capacity (Mbps)');
grid on;
legend('Average Total Capacity', 'Max Capacity Point');
hold off;
