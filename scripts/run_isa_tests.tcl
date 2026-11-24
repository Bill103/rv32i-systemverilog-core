#!/usr/bin/env tclsh

set script_dir [file dirname [file normalize [info script]]]
set repo_dir [file normalize [file join $script_dir ..]]
set build_dir   [file join $repo_dir build]
set hex_dir     [file join $build_dir riscv-tests]
set sim_out     [file join $build_dir riscv_test.out]

proc source_files {repo_dir patterns} {
    # Expand source globs and remove duplicate paths
    set files {}
    foreach pattern $patterns {
        foreach file [glob -nocomplain [file join $repo_dir $pattern]] {
            lappend files $file
        }
    }
    return [lsort -unique $files]
}

set rtl_patterns [list \
    src/fetch/*.sv \
    src/decode/*.sv \
    src/execute/*.sv \
    src/memory/*.sv \
    src/control/*.sv \
    src/pipeline/*.sv \
    src/core.sv \
    tb/riscv_test_tb.sv]

set sources [source_files $repo_dir $rtl_patterns]

proc compile_sim {sim_out sources} {
    set cmd [list iverilog -g2012 -o $sim_out]
    lappend cmd {*}$sources
    puts "Compiling RTL and testbench with iverilog"
    if {[catch {exec {*}$cmd 2>@1} output]} {
        puts stderr "Compilation Error:\n$output"
        error "iverilog compilation failed"
    }
    puts "Compilation successful"
}

compile_sim $sim_out $sources

set all_hex_files [lsort [glob -nocomplain [file join $hex_dir *.hex]]]

set skip_tests {fence_i ma_data}

if {[llength $argv] == 0} {
    # If no arguments are passed, run all tests except unsupported ones
    set tests_to_run {}
    foreach file $all_hex_files {
        set name [file rootname [file tail $file]]
        if {$name in $skip_tests} {
            continue
        }
        lappend tests_to_run $name
    }
} else {
    # If user passed arguments run those
    set tests_to_run $argv
}

set passed 0
set failed 0
set failed_tests {}

foreach test_name $tests_to_run {
    set hex_file [file join $hex_dir "${test_name}.hex"]

    # Check if the hex file actually exists
    if {![file exists $hex_file]} {
        puts stderr "\[WARN\] No hex file found for test $test_name (skipping)"
        continue
    }
    # Run vvp
    set vvp_cmd [list vvp $sim_out "+HEX=$hex_file" "+TESTNAME=$test_name"]
    set status [catch {exec {*}$vvp_cmd 2>@1} sim_output]

    if {$status == 0 && [string match {*\[PASS\]*} $sim_output]} {
        incr passed
        puts $sim_output
    } else {
        incr failed
        lappend failed_tests $test_name
        puts $sim_output
    }
}

puts "Total tests passed $passed"
puts "Total tests failed $failed"
if {$failed > 0} {
    puts "Failed tests $failed_tests"
    exit 1
}
