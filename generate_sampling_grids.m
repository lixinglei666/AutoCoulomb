function generate_sampling_grids()
    clc; clear; close all;

    % 定义其他参数(此处为研究区范围)
    minlon = 120; % deg
    maxlon = 122.5; % deg
    minlat = 21.5; % deg
    maxlat = 25.5; % deg
    dlon = 0.01; % deg
    dlat = 0.01; % deg

    % 读取深度信息
    depths = load('depths.txt'); % 深度信息存储在depths.txt文件中

    % 生成不同的sampling_grids文件
    for i = 1:length(depths)
        depth = depths(i);
       % 判断depth是否为整数
        if mod(depth, 1) == 0
            outputfile = sprintf('../grid/sampling_grids_%d.in', depth);
        else
            outputfile = sprintf('../grid/sampling_grids_%.1f.in', depth);
        end
        preproc_sampling_grids(minlon, maxlon, minlat, maxlat, dlon, dlat, depth, outputfile);
    end
end
