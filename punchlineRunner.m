% masses = 1000:5000:(5.972 * 10^6);
% velocities = 10000:1000:72000;

% masses = 1:51;
% velocities = 1:10;
function punchlineRunner()
	
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
		results
		contourf(masses, velocities, results);
		hold on
		[C, h] = contour(masses, velocities, results, [0, 0], 'LineWidth', 3, 'LineColor', 'w');
		xlabel('mass (kg)');
		ylabel('velocities (m/s)');
		ax = gca;
		ax.XScale = 'log';
		caxis([0 60000]);
		colormap('winter')
		cb = colorbar;
		ylabel(cb, 'height above the ground (m)')
		title([num2str(masses(1)), ' to ', num2str(masses(end)), ' kg; ', num2str(velocities(1)), ' to ', num2str(velocities(end)), ' m/s']);
		drawnow
		
		keyboard;
	end

end