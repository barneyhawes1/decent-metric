### settings functions ###

proc metric_drink_filename {} {
    if {[info exists ::metric_drink] != 1} { set ::metric_drink "A" }
    return "[skin_directory]/userdata/drink-$::metric_drink.tdb"
}

proc append_file {filename data} {
    set success 0
    set errcode [catch {
        set fn [open $filename a]
        puts $fn $data
        close $fn
        set success 1
    }]
    if {$errcode != 0} {
        msg "append_file $::errorInfo"
    }
    return $success
}

proc save_metric_array_to_file {arrname fn} {
    upvar $arrname item
    set metric_data {}
    foreach k [lsort -dictionary [array names item]] {
        set v $item($k)
        append metric_data [subst {[list $k] [list $v]\n}]
    }
    write_file $fn $metric_data
}

proc apply_metric_settings {} {
    if {$::settings(profile_filename) != $::metric_drink_settings(profile_filename)} {
        select_profile $::metric_drink_settings(profile_filename)
        set ::metric_pending_send_to_de1 1
    }
}

proc save_metric_settings {} {
    save_metric_array_to_file ::metric_drink_settings [metric_drink_filename]
    apply_metric_settings   
}

proc set_default_setting { varname value } {
    if {[info exists $varname] != 1} { set $varname $value }
}

proc load_metric_settings {} {
    array set ::metric_drink_settings [encoding convertfrom utf-8 [read_binary_file [metric_drink_filename]]]
    set_default_setting ::metric_drink_settings(profile_filename) "default"
    set_default_setting ::metric_drink_settings(beans) [translate "Unknown"]
    set_default_setting ::metric_drink_settings(grind) $::metric_setting_grind_default
    set_default_setting ::metric_drink_settings(dose) $::metric_setting_dose_default
    set_default_setting ::metric_drink_settings(ratio) $::metric_setting_ratio_default
    set_default_setting ::metric_drink_settings(yield) $::metric_setting_yield_default
    apply_metric_settings
}

proc adjust_setting {varname delta minval maxval} {
	if {[info exists $varname] != 1} { set $varname 0 }
	set currentval [subst \$$varname]
	set newval [expr $currentval + $delta]
	set newval [round_one_digits $newval]
	if {$newval > $maxval} {
		set $varname $maxval
	} elseif {$newval < $minval} {
		set $varname $minval
	} else {
		set $varname [round_one_digits $newval]
	}
	return $newval
}