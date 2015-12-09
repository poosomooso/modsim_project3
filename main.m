%current initm: 80
%current initv: -11*1000
function res = main(initm, initv)

	%%  Initiate variables
	gravity = 9.8;
	%density from http://meteorites.wustl.edu/id/density.htm
	mdensity = 3166.5; %weighted average of all meteors, kg/m^3
	dragcoef = .47; %Drag coefficient.
	%evap = (6.05*10^6)*1000; %Energy to vaporize one kg of meteorite
	%http://uregina.ca/~astro/Hoba.pdf
	%J/kg
	evap = 5*10^6;
	inith = 80*1000; %m. Initial height above sea level.
	initT = altTemp(inith);
	R = 287.053; %J/kg-K. The specific gas constant.

	% http://www.engineersedge.com/heat_transfer/convective_heat_transfer_coefficients__13378.htm
	heatcoef = 2000; %Forced convection, molten metal and air. Can be anywhere from 2000-45000.

		function res = flows(~, y)
			height = y(1);
			vel = y(2);
			mass = y(3);
			temp = y(4);

			dh = vel;
			dv = velflow(y(2), mass, height);
			
			%to find energy ablated
			%find energy lost to drag
			%divide by evap
			%grams evaporated / 1000 = kg
			%problem: residual heat does not exist
			SA = 4*pi*(((3*mass)/(4*pi*mdensity))^(2/3));
			dragE = .5*curralt(height)*dragcoef*pi*((3*mass/(4*pi*mdensity))^(2/3))*vel^2*dh;
			energy = dragE + heatcoef*SA*(altTemp(height) - temp);
			dm = (energy/evap);
			
			dt = (-dragE)/(mass*10^3); %10^3 is specific heat
			
			%need a function (maybe) that gives us the temperature at a
			%specific altitude
			%add convection to the energy lost
			
			res = [dh; dv; dm; dt];
		end

		function res = velflow(v, m, height)
			adens = curralt(height);
			drag = .5*curralt(height)*dragcoef*pi*((3*m/(4*pi*mdensity))^(2/3))*v^2;
			res = (-m*gravity+drag)/m;

		end
	vel = 0;
	%%  Initialize variables for air density.

	presSeaLev = 101.325*1000;%pascals
	seaLevTemp = 288.15; %K
	tempLapse = .0065; %K/m
	r = 8.31447; %J/(molK)
	molarmass = .0289644; %kg/mol
	absTemp = 288.15; %k, == 15 C

	%%  Find air density based on current altitude/air pressure.

		function res = curralt(curheight)
			% http://www.braeunig.us/space/atmmodel.htm
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
	function res = altTemp(curheight)
		upLimTropo = 12000; %m
		midLimStrato = 32000;
			upLimStrato = 47000; %m
			upLimMeso = 85000; %m
			h = curheight / 1000; %m to km

			if curheight < upLimTropo
				%only valid in troposphere
				res = 288-6.5*h;
			elseif curheight < midLimStrato
				res = 196.65+h;
			elseif curheight < upLimStrato
				%only valid in stratosphere
				res = 139.05+2.8*h;
			elseif curheight < upLimMeso
				%only valid in mesosphere
				res = 413.45-2.8*h;
			else
				res = 0;
			end
	end

	%%  Plot air density vs Altitude
% 	results = [inith; initv;initm];
% 	index = 1;
% 	for i = linspace(1,80000)
% 		results(index) = altTemp(i);
% 		index = index + 1;
% 	end
% 	figure;
% 	plot(results-270, linspace(20000,80000));
% 	title('Temperature change as altitude changes');
% 	ylabel('Altitude (m)');
% 	xlabel('Temp (C)');

% 	results = [inith; initv;initm];
% 	index = 1;
% 	for i = linspace(1,80000)
% 		results(index) = curralt(i);
% 		index = index + 1;
% 	end
% 	figure;
% 	plot(linspace(1,80000), results);
% 	title('Air density as altitude changes');
% 	ylabel('Air density');
% 	xlabel('Altitude');

	%%  Initiate Event- Meteor hits Earth

		function [value,isterminal,direction] = Events(t,S)
			value = +(S(1) > 0 && S(3) > 10^-20); % Extract the current height.
			isterminal = 1; % Stop the integration if height crosses zero or if distance crosses 97 m.
			direction = -1; % But only if the height or distance is decreasing.
		end

	%%  Stuff for Ode45
	initialTime = 0; %Seconds
	finalTime = 20*60; %Seconds
	options = odeset('Events', @Events);

	%%  Ode45 + Graphs
	[T,Y] = ode23(@flows, [initialTime, finalTime], [inith, initv, initm, initT], options);
% 	figure;
% 	plot(T, Y(:,2));
% 	%axis([min(T), max(T), 0, max(Y(:,2))]);
% 	axis([min(T), max(T), -inf, inf]);
% 	axis ij
% 	title([num2str(initm), ' kg, ', num2str(inith), ' m, ', num2str(initv), ' m/s']);
% 	xlabel('Time (Seconds)');
% 	ylabel('Velocity (m/s)');
	
	res = [T(end), Y(end, 1)];
end