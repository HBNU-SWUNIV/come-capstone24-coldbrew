% SNR 설정 및 변환 함수
SNRdB = 10; % SNR = 10 dB (Assumption)
SNR_linear = 10^(SNRdB / 10);

% 통신 성능 계산 함수 (SNR -> Capacity)
calculate_capacity = @(h, distance) log2(1 + SNR_linear * abs(h).^2 ./ distance.^2); % SNR 기반 용량 계산

% 반복 횟수 설정
num_iterations = 1000; % 1000회 반복

% 결과를 저장할 변수 초기화
all_average_capacity_case1 = [];
all_aggregate_capacity_case1 = [];
all_average_capacity_case2 = [];
all_aggregate_capacity_case2 = [];
all_average_capacity_case3 = [];
all_aggregate_capacity_case3 = [];
all_average_capacity_case4 = [];
all_aggregate_capacity_case4 = [];

% 통신 시작 시간 및 지속 시간 설정
comm_start_case1 = 10; % Case 1은 10초 후 통신 시작
comm_duration_case1 = 10; % 10초 동안 통신
comm_start_case2 = 11; % Case 2는 11초 후 통신 시작
comm_duration_case2 = 8; % 8초 동안 통신
comm_start_case3 = 12; % Case 3은 12초 후 통신 시작
comm_duration_case3 = 6; % 6초 동안 통신
comm_start_case4 = 12; % Case 4는 12초 후 통신 시작
comm_duration_case4 = 6; % 6초 동안 통신

for iter = 1:num_iterations
    %% Case 1: 정사각형 비행 경로 및 성능 계산
    side_length = 12.5;
    distances_case1 = [];
    capacities_case1 = [];
    drone_pos = start_point;

    % 비행 경로 및 성능 계산
    prev_drone_pos = drone_pos;
    for t = linspace(comm_time, flight_time, (flight_time-comm_interval)/comm_interval + 1)
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

        % 거리 및 통신 성능 계산
        distances = sqrt((drone_pos(1) - user_x).^2 + (drone_pos(2) - user_y).^2 + (z_height - user_z).^2);
        distances_case1 = [distances_case1; distances];

        % Fading Channel 상태 생성 및 용량 계산
        h = 1/sqrt(2) * (randn(1, N_users) + 1j * randn(1, N_users));
        capacities_case1 = [capacities_case1; calculate_capacity(h, distances)];

        prev_drone_pos = drone_pos;
    end

    %% Case 2: 큰 원형 비행 경로 및 성능 계산
    final_point_case2 = [44, 33, z_height];  % 드론이 원형 비행을 시작하는 지점
    center_case2 = [49.09, 36.82, z_height];  % 원의 중심 좌표
    distances_case2 = [];
    capacities_case2 = [];
    drone_pos = final_point_case2;

    % 원형 비행 경로 설정
    r_case2 = 40 / (2 * pi); % 원주가 40m인 경우 반지름 계산
    theta_0_case2 = atan2(final_point_case2(2) - center_case2(2), final_point_case2(1) - center_case2(1));

    for t = linspace(comm_time, flight_time, (flight_time - comm_interval) / comm_interval + 1)
        theta = theta_0_case2 + 2 * pi * (t - comm_time) / (flight_time - comm_time);

        drone_pos(1) = center_case2(1) + r_case2 * cos(theta);
        drone_pos(2) = center_case2(2) + r_case2 * sin(theta);

        % 거리 계산 및 저장
        distances = sqrt((drone_pos(1) - user_x).^2 + (drone_pos(2) - user_y).^2 + (z_height - user_z).^2);
        distances_case2 = [distances_case2; distances];

        % 통신 성능 계산
        h = 1/sqrt(2)*(randn(1, N_users) + 1j*randn(1, N_users));
        capacities_case2 = [capacities_case2; calculate_capacity(h, distances)];
    end

    %% Case 3: 작은 원형 비행 경로 및 성능 계산
    final_point_case3 = [48, 36, z_height];
    center_case3 = [51.82, 38.86, z_height];
    distances_case3 = [];
    capacities_case3 = [];
    drone_pos = final_point_case3;

    r_case3 = 30 / (2 * pi);
    theta_0_case3 = atan2(final_point_case3(2) - center_case3(2), final_point_case3(1) - center_case3(1));

    for t = linspace(comm_time, flight_time, (flight_time - comm_interval) / comm_interval + 1)
        theta = theta_0_case3 + 2 * pi * (t - comm_time) / (flight_time - comm_time);

        drone_pos(1) = center_case3(1) + r_case3 * cos(theta);
        drone_pos(2) = center_case3(2) + r_case3 * sin(theta);

        % 거리 계산 및 저장
        distances = sqrt((drone_pos(1) - user_x).^2 + (drone_pos(2) - user_y).^2 + (z_height - user_z).^2);
        distances_case3 = [distances_case3; distances];

        % 통신 성능 계산
        h = 1/sqrt(2)*(randn(1, N_users) + 1j*randn(1, N_users));
        capacities_case3 = [capacities_case3; calculate_capacity(h, distances)];
    end

    %% Case 4: 호버링 상태에서 성능 계산
    final_point_case4 = [48, 36, z_height];
    distances_case4 = [];
    capacities_case4 = [];
    hover_time = 6;
    hover_pos = final_point_case4;

    % 호버링 동안 거리 계산 및 통신 성능 계산
    for t = linspace(0, hover_time, hover_time / comm_interval)
        distances = sqrt((hover_pos(1) - user_x).^2 + (hover_pos(2) - user_y).^2 + (z_height - user_z).^2);
        distances_case4 = [distances_case4; distances];

        % 통신 성능 계산 (Fading 채널 상태 생성)
        h = 1/sqrt(2)*(randn(1, N_users) + 1j*randn(1, N_users));
        capacities_case4 = [capacities_case4; calculate_capacity(h, distances)];
    end

    %% 통신 구간 설정 및 결과 출력
    capacities_case1_full = zeros(size(capacities_case1));
    capacities_case2_full = zeros(size(capacities_case2));
    capacities_case3_full = zeros(size(capacities_case3));
    capacities_case4_full = zeros(size(capacities_case4));

    % 통신 구간 설정
    time_indices_case1 = find(linspace(0, flight_time, size(capacities_case1,1)) >= comm_start_case1 & ...
        linspace(0, flight_time, size(capacities_case1,1)) <= comm_start_case1 + comm_duration_case1);
    
    time_indices_case2 = find(linspace(0, flight_time, size(capacities_case2,1)) >= comm_start_case2 & ...
        linspace(0, flight_time, size(capacities_case2,1)) <= comm_start_case2 + comm_duration_case2);
    
    time_indices_case3 = find(linspace(0, flight_time, size(capacities_case3,1)) >= comm_start_case3 & ...
        linspace(0, flight_time, size(capacities_case3,1)) <= comm_start_case3 + comm_duration_case3);
    
    time_indices_case4 = find(linspace(0, flight_time, size(capacities_case4,1)) >= comm_start_case4 & ...
        linspace(0, flight_time, size(capacities_case4,1)) <= comm_start_case4 + comm_duration_case4);

    % 통신 구간에만 용량 값을 넣음
    capacities_case1_full(time_indices_case1, :) = capacities_case1(time_indices_case1, :);
    capacities_case2_full(time_indices_case2, :) = capacities_case2(time_indices_case2, :);
    capacities_case3_full(time_indices_case3, :) = capacities_case3(time_indices_case3, :);
    capacities_case4_full(time_indices_case4, :) = capacities_case4(time_indices_case4, :);

    % 평균 및 총합 용량 저장
    all_average_capacity_case1 = [all_average_capacity_case1; mean(capacities_case1_full, 1)];
    all_aggregate_capacity_case1 = [all_aggregate_capacity_case1; sum(capacities_case1_full, 1)];
    
    all_average_capacity_case2 = [all_average_capacity_case2; mean(capacities_case2_full, 1)];
    all_aggregate_capacity_case2 = [all_aggregate_capacity_case2; sum(capacities_case2_full, 1)];
    
    all_average_capacity_case3 = [all_average_capacity_case3; mean(capacities_case3_full, 1)];
    all_aggregate_capacity_case3 = [all_aggregate_capacity_case3; sum(capacities_case3_full, 1)];
    
    all_average_capacity_case4 = [all_average_capacity_case4; mean(capacities_case4_full, 1)];
    all_aggregate_capacity_case4 = [all_aggregate_capacity_case4; sum(capacities_case4_full, 1)];
end

% CSV 파일로 저장 (반복문 밖에서 수행)
writematrix(all_average_capacity_case1, 'average_capacity_case1.csv');
writematrix(all_aggregate_capacity_case1, 'aggregate_capacity_case1.csv');

writematrix(all_average_capacity_case2, 'average_capacity_case2.csv');
writematrix(all_aggregate_capacity_case2, 'aggregate_capacity_case2.csv');

writematrix(all_average_capacity_case3, 'average_capacity_case3.csv');
writematrix(all_aggregate_capacity_case3, 'aggregate_capacity_case3.csv');

writematrix(all_average_capacity_case4, 'average_capacity_case4.csv');
writematrix(all_aggregate_capacity_case4, 'aggregate_capacity_case4.csv');
