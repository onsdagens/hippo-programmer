# Vivado in project mode is less bad, pick part here, we use arty a35t dev board
create_project arty ./vivado/ -force -part xc7a35ticsg324-1L;


# Get file list from bender
set filelist [exec bender script flist]

# Split the bender returned string into something useful
set lines [split $filelist "\n"]

# Remove the last empty line if it exists (Bender artifact)
if {[llength $lines] > 0 && [string length [lindex $lines end]] == 0} {
    set lines [lrange $lines 0 end-1]
}

# Split the file list into source files and constraint files
set source_files {}
set constraint_files {}

foreach path $lines {
  if {[string match "*.xdc" $path]} {
    lappend constraint_files $path
  } else {
    lappend source_files $path
  }
}

# Add source files to default fileset
add_files -norecurse -fileset [current_fileset] $source_files

# Add constraints to constraint fileset
add_files -norecurse -fileset constrs_1 $constraint_files

foreach const $constraint_files {
  if {[string match "*impl.xdc" $const]} {
    set_property used_in_synthesis false [get_files $const]
  }
}

set_property verilog_define [list \
    TARGET_FPGA \
    TARGET_SYNTHESIS \
    TARGET_VIVADO \
    TARGET_XILINX \
] [current_fileset]

set_property verilog_define [list \
    TARGET_FPGA \
    TARGET_SYNTHESIS \
    TARGET_VIVADO \
    TARGET_XILINX \
] [current_fileset -simset]

# generate a reasonable compile order
update_compile_order -fileset [current_fileset]

# start Vivado GUI (this can be omitted)
start_gui
