
% 3D 그리드 맵 생성
mapSize = [100, 100, 50];
map3D = zeros(mapSize, 'uint8');

% 장애물 추가 (1개의 원통형 건물과 2개의 사각형 건물)
[x, y] = meshgrid(1:100, 1:100);

% 원통형 건물
center = [50, 50];
radius = 15;
height = 40;
circle = (x - center(1)).^2 + (y - center(2)).^2 <= radius^2;
for z = 1:height
    map3D(:,:,z) = map3D(:,:,z) | circle;
end

% 사각형 건물 1
map3D(20:30, 20:30, 1:25) = 1;

% 사각형 건물 2
map3D(70:80, 70:80, 1:35) = 1;

% 시작점과 목표점 설정
start = [10, 10, 5];
goal = [90, 90, 45];

% A* 경로 계획
[optimal_path, actual_path] = astar3D(map3D, start, goal);

% 2D 결과 시각화 (위에서 본 모습)
figure;
hold on;

% 건물 표시 (2D)
[x, y, ~] = ind2sub(size(map3D), find(max(map3D, [], 3) == 1));
scatter(x, y, 50, [0.7 0.7 0.7], 'filled', 'MarkerEdgeColor', 'none');

% 경로 표시 (2D)
if ~isempty(optimal_path)
    plot(optimal_path(:,1), optimal_path(:,2), 'm-', 'LineWidth', 2);
    plot(actual_path(:,1), actual_path(:,2), 'c-', 'LineWidth', 2);
end

% 시작점과 목표점 표시 (2D)
plot(start(1), start(2), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot(goal(1), goal(2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');

xlabel('X'); ylabel('Y');
title('2D A* 경로 계획 (위에서 본 모습)');
grid on;
legend('건물', '최적 경로', '실제 경로', '시작점', '목표점', 'Location', 'southeast');
axis equal;

% 2D 이미지 저장
saveas(gcf, 'path_planning_2D.png');

% 3D 결과 시각화
figure;
hold on;

% 건물 (물리적 장애물) 표시
[y, x, z] = ind2sub(size(map3D), find(map3D == 1)); % x축과 y축 위치 변경
scatter3(y, x, z, 50, [0.7 0.7 0.7], 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.3);

% 경로 표시 (3D)
if ~isempty(optimal_path)
    plot3(optimal_path(:,2), optimal_path(:,1), optimal_path(:,3), 'm-', 'LineWidth', 2); % x축과 y축 위치 변경
    plot3(actual_path(:,2), actual_path(:,1), actual_path(:,3), 'c-', 'LineWidth', 2); % x축과 y축 위치 변경
end

% 시작점과 목표점 표시
plot3(start(2), start(1), start(3), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g'); % x축과 y축 위치 변경
plot3(goal(2), goal(1), goal(3), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); % x축과 y축 위치 변경

xlabel('Y'); ylabel('X'); zlabel('Z'); % x축과 y축 레이블 변경
title('3D A* 경로 계획');
grid on;
view(3);
legend('건물', '최적 경로', '실제 경로', '시작점', '목표점', 'Location', 'southeast');
axis equal;

% 3D 이미지 저장
saveas(gcf, 'path_planning_3D.png');

function [optimal_path, actual_path] = astar3D(map, start, goal)
    [rows, cols, heights] = size(map);
    
    % 장애물 팽창
    inflated_map = inflateObstacles(map, 2);  % 2는 팽창 정도
    
    % 휴리스틱 함수
    heuristic = @(a, b) sqrt(sum((a - b).^2));
    
    % 시작 노드 초기화
    startNode = struct('pos', start, 'g', 0, 'h', heuristic(start, goal), 'f', 0);
    
    openSet = PriorityQueue();
    openSet.push(startNode, startNode.f);
    
    closedSet = false(size(inflated_map));
    parents = cell(size(inflated_map));
    
    while ~openSet.isEmpty()
        current = openSet.pop();
        
        if all(current.pos == goal)
            optimal_path = reconstructPath(parents, start, goal);
            optimal_path = optimizePath(optimal_path, inflated_map);
            
            actual_path = optimal_path + randn(size(optimal_path)) * 0.05;
            actual_path = adjustPathForObstacles(actual_path, inflated_map);
            actual_path = smoothPath(actual_path, 0.5, 20, inflated_map);
            actual_path = simplifyPath(actual_path, inflated_map);
            
            return;
        end
        
        closedSet(current.pos(1), current.pos(2), current.pos(3)) = true;
        
        % 이웃 노드 탐색 (26방향)
        for dx = -1:1
            for dy = -1:1
                for dz = -1:1
                    if dx == 0 && dy == 0 && dz == 0
                        continue;
                    end
                    
                    newPos = current.pos + [dx, dy, dz];
                    
                    if newPos(1) < 1 || newPos(1) > rows || ...
                       newPos(2) < 1 || newPos(2) > cols || ...
                       newPos(3) < 1 || newPos(3) > heights || ...
                       closedSet(newPos(1), newPos(2), newPos(3))
                        continue;
                    end
                    
                    % 건물 내부로 이동하는 것을 방지
                    if inflated_map(newPos(1), newPos(2), newPos(3)) == 1
                        continue;
                    end
                    
                    % 건물 엣지를 따라 이동
                    if isNearObstacle(inflated_map, newPos)
                        extraCost = 1;  % 엣지를 따라가는 비용
                    else
                        extraCost = 10; % 건물에서 멀어지는 비용
                    end
                    
                    % 수직 이동에 대한 추가 비용
                    if dz ~= 0
                        extraCost = extraCost + 5;
                    end
                    
                    newG = current.g + norm([dx, dy, dz]) + extraCost;
                    newH = heuristic(newPos, goal);
                    newF = newG + newH;
                    
                    if ~isempty(parents{newPos(1), newPos(2), newPos(3)})
                        if newG >= parents{newPos(1), newPos(2), newPos(3)}.g
                            continue;
                        end
                    end
                    
                    newNode = struct('pos', newPos, 'g', newG, 'h', newH, 'f', newF);
                    parents{newPos(1), newPos(2), newPos(3)} = current;
                    openSet.push(newNode, newF);
                end
            end
        end
    end
    
    optimal_path = [];
    actual_path = [];
end

function path = reconstructPath(parents, start, goal)
    path = goal;
    current = goal;
    while ~isequal(current, start)
        parent = parents{current(1), current(2), current(3)};
        path = [parent.pos; path];
        current = parent.pos;
    end
end

function adjusted_path = adjustPathForObstacles(path, map)
    adjusted_path = path(1,:);
    for i = 2:size(path, 1)
        start_point = adjusted_path(end, :);
        end_point = path(i, :);
        
        if isCollision(start_point, end_point, map)
            intermediate_points = findSafeIntermediatePoints(start_point, end_point, map);
            adjusted_path = [adjusted_path; intermediate_points];
        else
            % 안전 마진 검사 추가
            if isNearObstacle(map, round(end_point))
                intermediate_points = findSafeIntermediatePoints(start_point, end_point, map);
                adjusted_path = [adjusted_path; intermediate_points];
            else
                adjusted_path = [adjusted_path; end_point];
            end
        end
    end
end
function inflated_map = inflateObstacles(map, inflation_size)
    inflated_map = map;
    [rows, cols, heights] = size(map);
    for x = 1:rows
        for y = 1:cols
            for z = 1:heights
                if map(x,y,z) == 1
                    for dx = -inflation_size:inflation_size
                        for dy = -inflation_size:inflation_size
                            for dz = -inflation_size:inflation_size
                                nx = x + dx;
                                ny = y + dy;
                                nz = z + dz;
                                if nx >= 1 && nx <= rows && ny >= 1 && ny <= cols && nz >= 1 && nz <= heights
                                    inflated_map(nx, ny, nz) = 1;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
function intermediate_points = findSafeIntermediatePoints(start, goal, map)
    direction = goal - start;
    distance = norm(direction);
    step_size = 1;  % 더 작은 스텝 크기 사용
    num_steps = ceil(distance / step_size);
    
    intermediate_points = [];
    current_point = start;
    
    for i = 1:num_steps
        next_point = start + (i / num_steps) * direction;
        if isCollision(current_point, next_point, map) || isNearObstacle(map, round(next_point))
            detour_point = findDetourPoint(current_point, next_point, map);
            if ~isequal(detour_point, current_point)
                intermediate_points = [intermediate_points; detour_point];
                current_point = detour_point;
            else
                break;  % 안전한 우회 경로를 찾지 못함
            end
        else
            current_point = next_point;
        end
        intermediate_points = [intermediate_points; current_point];
    end
end


function detour_point = findDetourPoint(start, goal, map)
    direction = goal - start;
    perpendicular1 = cross(direction, [0, 0, 1]);
    perpendicular2 = cross(direction, perpendicular1);
    perpendicular1 = perpendicular1 / norm(perpendicular1);
    perpendicular2 = perpendicular2 / norm(perpendicular2);
    
    for radius = 1:10
        for angle = 0:pi/8:2*pi
            test_point = start + direction * 0.5 + ...
                         (perpendicular1 * cos(angle) + perpendicular2 * sin(angle)) * radius;
            test_point = round(test_point);
            if all(test_point > 0) && all(test_point <= size(map)) && ...
               map(test_point(1), test_point(2), test_point(3)) == 0 && ...
               ~isNearObstacle(map, test_point)
                detour_point = test_point;
                return;
            end
        end
    end
    detour_point = start; % 안전한 지점을 찾지 못한 경우 시작점 반환
end

function collision = isCollision(start, goal, map)
    t = 0:0.1:1;
    line_points = start + (goal - start) .* t';
    for j = 1:size(line_points, 1)
        point = round(line_points(j, :));
        if all(point > 0) && all(point <= size(map)) && map(point(1), point(2), point(3)) == 1
            collision = true;
            return;
        end
    end
    collision = false;
end
function simplified_path = simplifyPath(path, map)
    simplified_path = path(1,:);
    i = 1;
    while i < size(path, 1)
        for j = size(path, 1):-1:i+1
            if ~isCollision(path(i,:), path(j,:), map)
                simplified_path = [simplified_path; path(j,:)];
                i = j;
                break;
            end
        end
        i = i + 1;
    end
end
function near = isNearObstacle(map, pos)
    [rows, cols, heights] = size(map);
    near = false;
    safety_margin = 3;  % 안전 마진 증가
    for dx = -safety_margin:safety_margin
        for dy = -safety_margin:safety_margin
            for dz = -safety_margin:safety_margin
                newPos = pos + [dx, dy, dz];
                if newPos(1) >= 1 && newPos(1) <= rows && ...
                   newPos(2) >= 1 && newPos(2) <= cols && ...
                   newPos(3) >= 1 && newPos(3) <= heights
                    if map(newPos(1), newPos(2), newPos(3)) == 1
                        near = true;
                        return;
                    end
                end
            end
        end
    end
end

function smoothed_path = smoothPath(path, alpha, iterations, map)
    smoothed_path = path;
    for iter = 1:iterations
        for i = 2:(size(smoothed_path, 1) - 1)
            new_pos = smoothed_path(i, :) + ...
                alpha * (smoothed_path(i-1, :) + smoothed_path(i+1, :) - 2 * smoothed_path(i, :));
            if ~isCollision(smoothed_path(i, :), new_pos, map) && ...
               ~isNearObstacle(map, round(new_pos)) && ...
               ~isCollision(smoothed_path(i-1, :), new_pos, map) && ...
               ~isCollision(new_pos, smoothed_path(i+1, :), map)
                smoothed_path(i, :) = new_pos;
            end
        end
    end
    % 최종 경로 조정
    smoothed_path = adjustPathForObstacles(smoothed_path, map);
end

function optimized_path = optimizePath(path, map)
    optimized_path = path;
    i = 2;
    while i < size(optimized_path, 1)
        prev = optimized_path(i-1,:);
        next = optimized_path(min(i+1, size(optimized_path, 1)),:);
        if ~isCollision(prev, next, map)
            optimized_path(i,:) = [];
        else
            i = i + 1;
        end
    end
end