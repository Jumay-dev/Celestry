%Система связи CELESTRI
% 63 КА на 1400км, 7 орбит, 48 гр., 
% 6 связей, спереди-сзади и ближайшие по бокам
clc; clear;

sattelites_count  = 63;
orbit_count = 7;
sattelites_on_orbit = 9;
orbit_step = 48;


first_orbit_angle = 0; % наклоненение первой орбиты относительно эклиптики (ОЭ)
first_sattelite_on_orbit_angle = 0; % наклонение первого спутника на орбите ОЭ

sattelites_step = (360 / 9) * pi/180;

sattelites_step * 180/pi;

lat_matrix = zeros(orbit_count, sattelites_on_orbit);
lng_matrix = zeros(orbit_count, sattelites_on_orbit);

table_of_coordinates = zeros(sattelites_count, 4);

table_of_wires = zeros(sattelites_count, 5); % номер текущего спутника и его связи

sattelite_number = 1;

% Определим градусные координаты системы

% i - номер орбиты
for i = 1 : orbit_count
    % j - номер аппарата на конкретной орбите
    first_orbit_angle = first_orbit_angle + orbit_step;
    for j = 1 : sattelites_on_orbit
        first_sattelite_on_orbit_angle = first_sattelite_on_orbit_angle + sattelites_step * 180/pi;
        lat_matrix(i,j) = first_orbit_angle;
        lng_matrix(i,j) = first_sattelite_on_orbit_angle;
        table_of_coordinates(sattelite_number, 1) = sattelite_number;
        table_of_coordinates(sattelite_number, 2) = i;
        table_of_coordinates(sattelite_number, 3) = first_orbit_angle;
        table_of_coordinates(sattelite_number, 4) = first_sattelite_on_orbit_angle;
        table_of_wires(sattelite_number, 1) = sattelite_number;
        % если аппарат не последний на орбите
        if (rem(sattelite_number, sattelites_on_orbit))
            % если аппарат первый на орбите, но не первый в группировке
            if (j == 1 && sattelite_number ~= 1)
                table_of_wires(sattelite_number, 2) = sattelite_number + (sattelites_on_orbit - 1);
                table_of_wires(sattelite_number, 3) = sattelite_number + 1;
            end
            
            % если аппарат первый в группировке
            if (sattelite_number == 1)
                table_of_wires(sattelite_number, 2) = sattelites_on_orbit;
                table_of_wires(sattelite_number, 3) = sattelite_number + 1;
            end
            
            % любой другой аппарат
            if (j ~= 1)
                table_of_wires(sattelite_number, 2) = sattelite_number - 1;
                table_of_wires(sattelite_number, 3) = sattelite_number + 1;
            end
        end
        
        % если аппарат последний на орбите
        if (rem(sattelite_number, sattelites_on_orbit) == 0)
            table_of_wires(sattelite_number, 2) = table_of_wires(sattelite_number - (sattelites_on_orbit - 1), 1);
            table_of_wires(sattelite_number, 3) = sattelite_number + 1;
        end

        sattelite_number = sattelite_number + 1;
    end
    first_sattelite_on_orbit_angle = 0;
end

table_of_coordinates

% Определим связи для каждого спутника в системе
for i = 1 : sattelites_count
    current_sattelite = table_of_coordinates(i, :);
    % сортировка
%     closer_right = zeros(2, 1);
%     closer_left = zeros(2, 1);
    left_sibling = 0;
    right_sibling = 0;
    
    current_sattelite_coords = [table_of_coordinates(i, 3), table_of_coordinates(j, 4)];
    % получаем соседние орбиты
    leftside_orbit_number = 0;
    rightside_orbit_number = 0;
    
    if (table_of_coordinates(i, 2) > 1 && table_of_coordinates(i, 2) < orbit_count)
        leftside_orbit_number = table_of_coordinates(i, 2) - 1;
        rightside_orbit_number = table_of_coordinates(i, 2) + 1;
    end
    if (table_of_coordinates(i, 2) == 1)
        % семантически не совсем понятно, но orbit_count еще и номер
        % последней орбиты
        leftside_orbit_number = orbit_count;
        rightside_orbit_number = table_of_coordinates(i, 2) + 1;
    end
    if (table_of_coordinates(i, 2) == orbit_count)
        leftside_orbit_number = table_of_coordinates(i, 2) - 1;
        rightside_orbit_number = 1;
    end
    
    for j = 1 : sattelites_count
        if (table_of_coordinates(j, 2) == leftside_orbit_number && table_of_coordinates(j, 4) == table_of_coordinates(i, 4))
            left_sibling = table_of_coordinates(j, 1);
        end
        if (table_of_coordinates(j, 2) == rightside_orbit_number && table_of_coordinates(j, 4) == table_of_coordinates(i, 4))
            right_sibling = table_of_coordinates(j, 1);
        end
    end
    
    table_of_wires(i, 4) = left_sibling;
    table_of_wires(i, 5) = right_sibling;
%     table_of_wires(i, 4) = closer_left(1, 1);
%     table_of_wires(i, 5) = closer_left(2, 1);
%     table_of_wires(i, 6) = closer_right(1, 1);
%     table_of_wires(i, 7) = closer_right(2, 1);
end

table_of_wires