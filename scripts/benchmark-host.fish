#!/usr/bin/env fish

set -l label "snapshot"
if test (count $argv) -ge 1
    set label $argv[1]
end

set -l script_dir (cd (dirname (status filename)); pwd)
set -l repo_root (realpath $script_dir/..)
set -l benchmark_dir "$repo_root/docs/benchmarking"
mkdir -p $benchmark_dir

set -l host_name (hostname -s)
set -l safe_label (string replace -ra '[^A-Za-z0-9._-]' '-' -- $label)
set -l timestamp (date '+%Y%m%d-%H%M%S')

set -l output_file
if test (count $argv) -ge 2
    set output_file $argv[2]
else
    set output_file "$benchmark_dir/benchmark-$host_name-$safe_label-$timestamp.txt"
end

set -l output_dir (dirname $output_file)
mkdir -p $output_dir

set -l fio_file (mktemp /tmp/benchmark-host.XXXXXX)

function cleanup --on-event fish_exit
    rm -f $fio_file
end

echo "writing benchmark log to: $output_file" >&2

begin
    echo "== host benchmark =="
    echo "hostname: $host_name"
    echo "label: $label"
    echo "timestamp: "(date --iso-8601=seconds)
    echo "output_file: $output_file"
    echo

    echo "== uname =="
    uname -a
    echo

    echo "== uptime =="
    uptime
    echo

    echo "== cmdline =="
    cat /proc/cmdline
    echo

    echo "== cpupower frequency-info =="
    cpupower frequency-info
    echo

    echo "== cpupower idle-info =="
    cpupower idle-info
    echo

    echo "== sysbench cpu =="
    sysbench cpu --threads=16 --time=20 run
    echo

    echo "== sysbench memory =="
    sysbench memory --threads=16 --time=20 run
    echo

    echo "== fio randread =="
    fio --name=randread --filename=$fio_file --size=1G --bs=4k --iodepth=32 --rw=randread --ioengine=io_uring --direct=1
    echo

    echo "== sensors =="
    sensors
end | tee $output_file
