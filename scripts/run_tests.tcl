#!/usr/bin/env tclsh

# Resolve paths from the script location, not the caller's working directory.
set script_dir [file dirname [file normalize [info script]]]
set repo_dir [file normalize [file join $script_dir ..]]
set build_dir [file join $repo_dir build tcl]

proc usage {} {
    puts "Usage: tclsh scripts/run_tests.tcl ?test ...?"
    puts ""
    puts "Tests: core controller immgen regfile alu fetch dmem all"
}

proc source_files {repo_dir patterns} {
    # Expand source globs and remove duplicate paths.
    set files {}
    foreach pattern $patterns {
        foreach file [glob -nocomplain [file join $repo_dir $pattern]] {
            lappend files $file
        }
    }
    return [lsort -unique $files]
}

proc run_test {repo_dir build_dir name source_patterns testbench} {
    # Compile one testbench, then let its assertions determine the result.
    set output_file [file join $build_dir ${name}.out]
    set sources [source_files $repo_dir $source_patterns]
    set compile_command [list iverilog -g2012 -I [file join $repo_dir src execute] -o $output_file]
    lappend compile_command {*}$sources [file join $repo_dir $testbench]

    puts "==> $name: compile"
    if {[catch {exec {*}$compile_command 2>@1} compile_output]} {
        puts $compile_output
        error "$name compilation failed"
    }

    puts "==> $name: simulate"
    if {[catch {exec vvp $output_file 2>@1} simulation_output]} {
        puts $simulation_output
        error "$name simulation failed"
    }
    puts $simulation_output
}

# Keep generated simulator binaries out of the source tree.
file mkdir $build_dir

# Each entry contains: name, RTL source patterns, and testbench path.
set tests [list \
    [list core [list src/control/*.sv src/decode/*.sv src/execute/*.sv src/fetch/*.sv src/memory/*.sv src/pipeline/*.sv src/core.sv] tb/core_tb.sv] \
    [list controller [list src/control/*.sv] tb/control/controller_tb.sv] \
    [list immgen [list src/decode/immgen.sv] tb/decode/immgen_tb.sv] \
    [list regfile [list src/decode/regfile.sv] tb/decode/regfile_tb.sv] \
    [list alu [list] tb/execute/alu_tb.sv] \
    [list fetch [list src/fetch/pc.sv src/fetch/imem.sv] tb/fetch/fetch_tb.sv] \
    [list dmem [list src/memory/dmem.sv] tb/memory/dmem_tb.sv]]

# No arguments, or "all", runs the complete suite.
set requested $argv
if {[llength $requested] == 0 || [lsearch -exact $requested all] >= 0} {
    set requested {core controller immgen regfile alu fetch dmem}
}

# Reject misspelled test names before compiling anything.
set known_tests {}
foreach test_definition $tests {
    lappend known_tests [lindex $test_definition 0]
}

foreach name $requested {
    if {[lsearch -exact $known_tests $name] < 0} {
        usage
        error "unknown test: $name"
    }
}

# Run each requested test and report all failures at the end.
set failures 0
foreach name $requested {
    set test_definition {}
    foreach candidate $tests {
        if {[lindex $candidate 0] eq $name} {
            set test_definition $candidate
            break
        }
    }
    set source_patterns [lindex $test_definition 1]
    set testbench [lindex $test_definition 2]

    if {[catch {run_test $repo_dir $build_dir $name $source_patterns $testbench} message]} {
        puts stderr "FAIL: $message"
        incr failures
    } else {
        puts "PASS: $name"
    }
}

if {$failures > 0} {
    error "$failures test(s) failed"
}

puts "All requested tests passed."