%current initm: 80
%current initv: -11*1000
function main(initm, initv)
    
%%  Initiate variables
	gravity = 9.8;
	mdensity = 3.1665; %weighted average of all meteors
	dragcoef = .47; %Drag coefficient.
	evap = (6.05*10^6)/1000; %Energy to vaporize one kg of meteorite
	inith = 80*1000; %m. Initial height above sea level.
    R = 287.053; %J/kg-K. The specific gas constant.
    
    heatcoef = 2000; %Forced convection, molten metal and air. Can be anywhere from 2000-45000.
	
	function res = flows(~, y)     
		height = y(1);
		vel = y(2);
		mass = y(3);
		
		dh = vel;
		dv = velflow(y(2), mass, height);
        
        SA = 4*pi*(((3*mass)/(4*pi*mdensity))^(2/3));
		dm = (0.5 * heatcoef * curralt(height) * vel^3 * SA) / evap;
		
		res = [dh; dv; dm];
	end

	function res = velflow(v, m, height)
		adens = curralt(height);
		drag = .5*curralt(height)*dragcoef*pi*((3*m/(4*pi*mdensity))^(2/3))*v^2;
		res = (-m*gravity+drag)/m;
		
    end

%%  Initialize variables for air density.

	presSeaLev = 101.325*1000;%pascals
	seaLevTemp = 288.15; %K
	tempLapse = .0065; %K/m
	r = 8.31447; %J/(molK)
	molarmass = .0289644; %kg/mol
	absTemp = 288.15; %k, == 15 C
	
%%  Find air density based on current altitude/air pressure.
    
	function res = curralt(curheight)
        upLimTropo = 12000; %m
        upLimStrato = 47000; %m
        upLimMeso = 85000; %m
        h = curheight / 1000; %m to km
        
        if curheight < upLimTropo
            %only valid in troposphere
            P = 101325.0 * (288.15 / (288.15 - 6.5 * h)) ^ (34.1632 / -6.5);
            Tm = 288.15 - (6.5 * h);
            res = P / (R*Tm);
        elseif curheight < upLimStrato
            %only valid in stratosphere
            %P = 868.0187 * ((228.65 / (228.65 + (2.8*(h - 32)))) ^ (34.1632/2.8));
            P = 5474.889 * (216.65 / (216.65 + (h-20)))^34.1632;
            %Tm = 139.05 + (2.8 * h);
            Tm = 196.65 + h;
            res = P / (R*Tm);
        elseif curheight < upLimMeso
            %only valid in mesosphere
            %P = 3.956420 * (214.65 / (214.65 - 2 * (h - 71))) ^ (34.1632 / -2);
            %Tm = 356.65 - 2.0 * h;
            P = 66.93887 * [270.65 / (270.65 - 2.8 * (h-51))]^(34.1632 / -2.8);
            Tm = 413.45 - 2.8 * h;
            res = P / (R*Tm);
        else
            res = 0;
        end
    end

%%  Plot air density vs Altitude
    results = [inith; initv;initm];
    index = 1;
	for i = linspace(20000,80000)
		results(index) = curralt(i);
        index = index + 1;
    end
    figure;
    plot(linspace(20000,80000), results);
    xlabel('Altitude (m)');
    ylabel('Air Density (kg/m^3)');
    
%%  Initiate Event- Meteor hits Earth
    
    function [value,isterminal,direction] = Events(t,S)
        value = +(S(1) > 0 && S(3) > 0); % Extract the current height.
        isterminal = 1; % Stop the integration if height crosses zero or if distance crosses 97 m.
        direction = -1; % But only if the height or distance is decreasing.
    end

%%  Stuff for Ode45
    initialTime = 0; %Seconds
    finalTime = 20*60; %Seconds
    options = odeset('Events', @Events);

%%  Ode45 + Graphs
    [T,Y] = ode45(@flows, [initialTime, finalTime], [inith, initv, initm], options)
    figure;
    plot(T, Y(:,1));
    axis([min(T), max(T), 0, max(Y(:,1))]);
    xlabel('Time (Seconds)');
    ylabel('Altitude (m)');

end