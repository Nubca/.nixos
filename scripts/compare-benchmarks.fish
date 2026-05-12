#!/usr/bin/env fish

set -l script_dir (cd (dirname (status filename)); pwd)
set -l repo_root (realpath $script_dir/..)
set -l benchmark_dir "$repo_root/docs/benchmarking"

if test (count $argv) -ne 2
    echo "usage: compare-benchmarks.fish <before-log> <after-log>"
    exit 1
end

function resolve_log --argument-names benchmark_root candidate
    if test -f $candidate
        echo $candidate
    else if test -f "$benchmark_root/$candidate"
        echo "$benchmark_root/$candidate"
    else
        echo $candidate
    end
end

set -l before (resolve_log $benchmark_dir $argv[1])
set -l after (resolve_log $benchmark_dir $argv[2])

for file in $before $after
    if not test -f $file
        echo "missing file: $file"
        exit 1
    end
end

function extract_first --argument-names pattern file
    rg -m 1 --replace '$1' $pattern $file
end

function extract_metric --argument-names label before_value after_value unit better
    echo "== $label =="
    echo "before: $before_value$unit"
    echo "after:  $after_value$unit"

    set -l delta (awk -v b="$before_value" -v a="$after_value" 'BEGIN {
        if (b == 0) {
            print "n/a"
        } else {
            printf "%.2f", ((a - b) / b) * 100
        }
    }')

    echo "delta:  $delta%"

    if test "$better" = "higher"
        awk -v b="$before_value" -v a="$after_value" 'BEGIN {
            if (a > b) print "trend: better"
            else if (a < b) print "trend: worse"
            else print "trend: unchanged"
        }'
    else if test "$better" = "lower"
        awk -v b="$before_value" -v a="$after_value" 'BEGIN {
            if (a < b) print "trend: better"
            else if (a > b) print "trend: worse"
            else print "trend: unchanged"
        }'
    end

    echo
end

set -l before_label (extract_first '^label:\s+(.*)$' $before)
set -l after_label (extract_first '^label:\s+(.*)$' $after)
set -l before_time (extract_first '^timestamp:\s+(.*)$' $before)
set -l after_time (extract_first '^timestamp:\s+(.*)$' $after)
set -l before_host (extract_first '^hostname:\s+(.*)$' $before)
set -l after_host (extract_first '^hostname:\s+(.*)$' $after)

echo "== benchmark logs =="
echo "before: $before_label on $before_host ($before_time)"
echo "after:  $after_label on $after_host ($after_time)"
echo "before file: $before"
echo "after file:  $after"
echo

set -l before_cpu (extract_first 'events per second:\s+([0-9.]+)' $before)
set -l after_cpu (extract_first 'events per second:\s+([0-9.]+)' $after)
extract_metric "sysbench cpu events/sec" $before_cpu $after_cpu "" "higher"

set -l before_mem (extract_first '^\s*102400\.00 MiB transferred \(([0-9.]+) MiB/sec\)' $before)
set -l after_mem (extract_first '^\s*102400\.00 MiB transferred \(([0-9.]+) MiB/sec\)' $after)
extract_metric "sysbench memory MiB/sec" $before_mem $after_mem "" "higher"

set -l before_iops (extract_first 'read: IOPS=([0-9.]+)k' $before)
set -l after_iops (extract_first 'read: IOPS=([0-9.]+)k' $after)
extract_metric "fio randread IOPS (k)" $before_iops $after_iops "" "higher"

set -l before_lat (extract_first '^\s+lat \(usec\): min=.* avg=([0-9.]+),' $before)
set -l after_lat (extract_first '^\s+lat \(usec\): min=.* avg=([0-9.]+),' $after)
extract_metric "fio average latency usec" $before_lat $after_lat "" "lower"

set -l before_cpu_temp (extract_first '^Package id 0:\s+\+([0-9.]+)°C' $before)
set -l after_cpu_temp (extract_first '^Package id 0:\s+\+([0-9.]+)°C' $after)
extract_metric "CPU package temp C" $before_cpu_temp $after_cpu_temp "" "lower"

set -l before_nvme_temp (extract_first '^Composite:\s+\+([0-9.]+)°C' $before)
set -l after_nvme_temp (extract_first '^Composite:\s+\+([0-9.]+)°C' $after)
extract_metric "NVMe temp C" $before_nvme_temp $after_nvme_temp "" "lower"

set -l before_idle (extract_first '^Available idle states:\s+(.*)$' $before)
set -l after_idle (extract_first '^Available idle states:\s+(.*)$' $after)
echo "== idle states =="
echo "before: $before_idle"
echo "after:  $after_idle"
