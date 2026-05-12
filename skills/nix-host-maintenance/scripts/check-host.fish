#!/usr/bin/env fish

function section --argument-names title
    echo
    echo "== $title =="
end

function maybe_run --argument-names label
    set -l cmd $argv[2..-1]
    if test (count $cmd) -eq 0
        section $label
        echo "no command provided"
        return 1
    end

    if type -q $cmd[1]
        section $label
        $cmd
    else
        section $label
        echo "missing command: $cmd[1]"
    end
end

echo "nNix host sanity check"
echo "timestamp: "(date --iso-8601=seconds)
echo "hostname: "(hostname -s)
echo "user: "(id -un)

maybe_run "uname" uname -a
maybe_run "uptime" uptime

section "kernel cmdline"
cat /proc/cmdline

section "cpu governor summary"
set -l governor_files /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
if test -e $governor_files[1]
    for file in $governor_files
        set -l cpu_name (path basename (path dirname (path dirname $file)))
        echo -n "$cpu_name: "
        cat $file
    end
else
    echo "no scaling_governor files found"
end

section "intel_pstate"
if test -f /sys/devices/system/cpu/intel_pstate/status
    echo -n "status: "
    cat /sys/devices/system/cpu/intel_pstate/status
else
    echo "intel_pstate status not present"
end

maybe_run "cpupower frequency-info" cpupower frequency-info
maybe_run "cpupower idle-info" cpupower idle-info
maybe_run "sensors" sensors

section "pci devices"
if type -q lspci
    lspci -nnk | rg -A 2 'VGA|3D|Display|Audio device|Non-Volatile memory controller'
else
    echo "missing command: lspci"
end

section "block devices"
if type -q lsblk
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
else
    echo "missing command: lsblk"
end

section "recent warning scan"
if test (id -u) -eq 0
    dmesg -T | rg -i 'error|warn|failed|vfio|amdgpu|nvrm|nvme|pcie|i915|thermal|throttle|usb'
else
    echo "run with sudo for dmesg warnings"
end
