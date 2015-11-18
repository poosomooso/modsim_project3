function main(initm, initv)
	gravity = 9.8;
	mdensity = 3.1665; %weighted average of all meteors
	dragcoef = .47;
	evap = 6.05*10^6; %necessary for mass calcs
	inith = 80*1000; %m
	
	function res = flows(~, y)
		height = y(1);
		vel = y(2);
		mass = y(3);
		
		dh = vel;
		dv = velflow(y(2), mass, height);
		dm = 0;
		
		res = [dh; dv; dm];
	end

	function res = velflow(v, m, height)
		drag = .5*curralt(height)*dragcoef*pi*((3*m/(4*pi*mdensity))^(2/3))*v^2
		res = (-m*gravity+drag)/m;
		
	end

	presSeaLev = 101.325*1000;%pascals
	h0 = 7*1000; %m
	function res = curralt(curheight)
		res = presSeaLev*exp(curheight/h0);
	end
	for i = logspace(0, 6)
		i
		curralt(i)/1000
	end
	flows(0, [inith, initv, initm])
	
end