% masses = 1000:5000:(5.972 * 10^6);
% velocities = 10000:1000:72000;

% masses = 1:51;
% velocities = 1:10;
function punchlineRunner()

% 	masses2 = 1000:1000:10000;
% 	masses3 = 10000:10000:100000;
% 	masses4 = 100000:100000:10^6;
% 	masses5 = 10^6:10^6:10^7;
% 	
% 	vel1 = -10000:-500:-30000;
% 	vel2 = -30000:-1000:-72000;
% 	
% 
% 	plotter(masses2, vel1);
% 	plotter(masses3, vel1);
% 	plotter(masses4, vel1);
% 	plotter(masses5, vel1);
% 
% 	plotter(masses2, vel2);
% 	plotter(masses3, vel2);
% 	plotter(masses4, vel2);
% 	plotter(masses5, vel2);

	masses6 = logspace(0, 10, 100);
	velocities6 = -72000:500:-10000;
	
	plotter(masses6, velocities6);

	function plotter(masses, velocities)
		i = 1;
		j = 1;
		results = zeros(length(velocities), length(masses));
		size(results)
		for m = masses
			for v = velocities

				endVals = main(m,v);
				results(i,j) = endVals(2);
				i = i+1;
			end
			j = j+1;
			i = 1;
		end
		figure;
		size(results)
		contourf(masses, velocities, results);
		hold on
		contour(masses, velocities, results, [0, 0], 'LineWidth', 3, 'LineColor', 'w');
		xlabel('mass (kg)');
		ylabel('velocities (m/s)');
		ax = gca;
		ax.XScale = 'log';
		caxis([0 60000]);
		colorbar;
		title([num2str(masses(1)), ' to ', num2str(masses(end)), ' kg; ', num2str(velocities(1)), ' to ', num2str(velocities(end)), ' m/s']);
		drawnow
	end

end