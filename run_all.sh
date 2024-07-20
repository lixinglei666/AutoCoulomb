#!/bin/bash

# 定义包含命令文件的目录
command_dir="commands"

# 获取命令文件列表
command_files=($(ls $command_dir/*.txt))

# 循环遍历每个文件并运行其中的命令
for file in "${command_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "Running command from file: $file"
        command=$(cat "$file")

        # 创建一个唯一的输出目录，使用时间戳和文件名
        timestamp=$(date +%Y%m%d_%H%M%S)
        output_dir="output_${file%.*}_$timestamp"
        mkdir -p "$output_dir"

        # 将命令中的输出目录参数替换为实际的输出目录
        command_with_output_dir="${command} -O $output_dir"

        echo "Executing: $command_with_output_dir"
        eval "$command_with_output_dir"
    else
        echo "File not found: $file"
    fi
done