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
		adens = curralt(height)
		drag = .5*curralt(height)*dragcoef*pi*((3*m/(4*pi*mdensity))^(2/3))*v^2
		res = (-m*gravity+drag)/m;
		
	end

	presSeaLev = 101.325*1000;%pascals
	seaLevTemp = 288.15; %K
	tempLapse = .0065; %K/m
	r = 8.31447; %J/(molK)
	molarmass = .0289644; %kg/mol
	absTemp = 288.15; %k, == 15 C
	
	function res = curralt(curheight)
		tempLapse*curheight/seaLevTemp %debugging
		pres = presSeaLev*(1-(tempLapse*curheight/seaLevTemp))^(gravity*molarmass/r/tempLapse)
		%set threshhold altitude? getting imaginary numbers >44323 m
		res = pres*molarmass/(r*(absTemp-tempLapse*curheight));
	end
	for i = linspace(44000,45000)
		i
		curralt(i)
	end
	flows(0, [inith, initv, initm])
	
end