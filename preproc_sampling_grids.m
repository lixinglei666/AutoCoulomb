function preproc_sampling_grids(minlon, maxlon, minlat, maxlat, dlon, dlat, depth, outputfile)
    % Calculate longitude and latitude ranges
    lon = minlon:dlon:maxlon;
    lat = minlat:dlat:maxlat;
    if lon(end) < maxlon
        lon = [lon maxlon];
    end
    if lat(end) < maxlat
        lat = [lat maxlat];
    end

    % Create meshgrid
    [lon, lat] = meshgrid(lon, lat);
    lon = lon(:);
    lat = lat(:);
    totalN = length(lon);

    % Write to output file
    fp = fopen(outputfile, 'wt');
    fprintf(fp, '%d\n', totalN);
    for i = 1:totalN
        fprintf(fp, '%13.6f%13.6f%13.6f\n', lat(i), lon(i), depth);
    end
    fclose(fp);

    % Display information
    path = pwd;
    n = find(path == '/');
    disp([mfilename, '.m: The sampling file was saved in the following directory:']);
    disp([path(1:max(n)), outputfile(4:end)]);
    disp(sprintf('total sampling points: %d\ndlon=%8.1f km dlat=%8.1f km', totalN, deg2rad(dlon) * 6378, deg2rad(dlat) * 6378));

    % Plot points
    figure;
    plot(lon, lat, 'r.');
    xlabel('Longitude(deg)');
    ylabel('Latitude(deg)');
    title('Gridded points');
    set(gca, 'FontSize', 20);
    set(gcf, 'color', 'w');
end
