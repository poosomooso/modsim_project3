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
		adens = curralt(height);
		drag = .5*curralt(height)*dragcoef*pi*((3*m/(4*pi*mdensity))^(2/3))*v^2;
		res = (-m*gravity+drag)/m;
		
	end

	presSeaLev = 101.325*1000;%pascals
	seaLevTemp = 288.15; %K
	tempLapse = .0065; %K/m
	r = 8.31447; %J/(molK)
	molarmass = .0289644; %kg/mol
	absTemp = 288.15; %k, == 15 C
	
	function res = curralt(curheight)
        upLimTropo = 12000; %m
        upLimStrato = 47000; %m
        upLimMeso = 85000; %m
        h = curheight / 1000; %m to km
        
        if curheight < upLimTropo
            %only valid in troposphere
            res = 101325.0 * (288.15 / (288.15 - 6.5 * h)) ^ (34.1632 / -6.5);
        elseif curheight < upLimStrato
            %only valid in stratosphere
            res = 868.0187 * ((228.65 / (228.65 + (2.8*(h - 32)))) ^ (34.1632/2.8));
        elseif curheight < upLimMeso
            %only valid in mesosphere
            res = 3.956420 * (214.65 / (214.65 - 2 * (h - 71))) ^ (34.1632 / -2);
        else
            res = 0;
        end
    end

    results = [];
    index = 1;
	for i = linspace(0,80000)
		results(index) = curralt(i);
        index = index + 1;
    end
    results
	flows(0, [inith, initv, initm])
	
end