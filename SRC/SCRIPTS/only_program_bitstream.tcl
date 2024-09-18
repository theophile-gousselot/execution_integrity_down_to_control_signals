set bitfile [lindex $argv 0]

if { [file exists $bitfile] != 1 } {
    puts "No bitfile $bitfile"
    quit
} else {
    puts "Using bitfile $bitfile"
}

set_property PROGRAM.FILE $bitfile $first_hw_device
program_hw_devices $first_hw_device
