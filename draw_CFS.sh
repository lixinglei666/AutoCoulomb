#!/bin/bash

psfile=coulomb.ps
pdffile="${psfile%.*}.pdf"
pngfile="${psfile%.*}.png"
gfortran ../CFSsrc/find_minmax_values/get_gmt_boundary.f90 -o get_gmt_boundary
sed '1d' $1 > tempgrids.txt
./get_gmt_boundary tempgrids.txt >/dev/null
range=$(awk '{printf("%13.6f/%13.6f/%13.6f/%13.6f\n"),$1,$2,$3,$4}' gmtbounds.txt | sed 's/ //g')
rm -rf tempgrids.txt gmtbounds.txt get_gmt_boundary
#range=102/106/30/34
projection=m1i
offx=1
offy=0.8
delta=1m
output_dir=$2  # 将输出目录作为参数传递
workdir="${output_dir}/CFS_map"
bshut=0

# 确保输出目录存在
mkdir -p "$workdir"

cd "$workdir"
coulomb="../coulomb.out" # 修正路径以匹配输出目录结构
cptfile=CFS.cpt
gmt makecpt -Cno_green -T-2/2/0.1 > $cptfile
gmt psbasemap -J$projection -R$range -Bpxa1 -Bpya1 -BSWne -K -X$offx -Y$offy >$psfile
if [ $bshut -eq 0 ]; then
    awk '{print $1,$2,$5}' $coulomb | gmt psxy -J -R -K -O -B -Ss0.1 -C$cptfile >>$psfile
else
    awk '{print $1,$2,$5}' $coulomb | blockmean -I$delta -R$range | surface -Gcoulomb.grd -I$delta -R$range
    grdimage -R -B coulomb.grd -C$cptfile -J$projection -K -O >> $psfile
fi
gmt psscale -Dn1.2/0.05+w2.5i/0.15i -J -R -C$cptfile -Ba1x+l"@~\104@~CFS" -By+l"bars" -K -O --FONT_ANNOT_PRIMARY=10p --FONT_LABEL=10p >>$psfile
gmt pscoast -R$range -J$projection -W1p -Dh -N1/1p -N2/0.25p -Bpxa1 -Bpya1 -BSEWN -K -O >> $psfile
# 读取运行次数，如果文件不存在则初始化为 0
count_file="../../../draw_count.txt"
if [[ ! -f $count_file ]]; then
    echo 0 > "$count_file"
fi
new_count=$(($(cat $count_file) + 1))
echo $new_count > $count_file
# 读取地震数据并添加标注
earthquake_file="../../../earthquakes.txt"
if [[ -f $earthquake_file ]]; then
    mapfile -t earthquakes < "$earthquake_file"
    len=${#earthquakes[@]}
    # 根据 new_count 计算 idx1 和 idx2
    idx1=0
    idx2=0
    n=1

    for (( idx1=0; idx1<len-1; idx1++ )); do
        for (( idx2=idx1+1; idx2<len; idx2++ )); do
            if (( n == new_count )); then
                break 2
            fi
            n=$((n + 1))
        done
    done

    if [[ $idx1 -lt $len && $idx2 -lt $len && $idx1 -ne $idx2 ]]; then
        echo "${earthquakes[$idx1]}" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' | gmt psmeca -J -R -K -O -CP3p -Sa0.5 -Gred -W1,black >> $psfile
        echo "${earthquakes[$idx2]}" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' | gmt psmeca -J -R -K -O -CP3p -Sa0.5 -Gred -W1,black >> $psfile
    fi
fi
ps2pdf $psfile
# 将 pdf 文件转换为 png，并设置背景颜色为白色
convert -density 300 "$pdffile" -background white -alpha remove "$pngfile"