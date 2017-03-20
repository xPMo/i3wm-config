#!/usr/bin/env perl
#
# Copyright 2014 Pierre Mavro <deimos@deimos.fr>
# Copyright 2014 Vivien Didelot <vivien@didelot.org>
#
# Licensed under the terms of the GNU GPL v3, or any later version.
#
# This script is meant to use with i3blocks. It parses the output of the "acpi"
# command (often provided by a package of the same name) to read the status of
# the battery, and eventually its remaining time (to full charge or discharge).
#
# The color will gradually change for a percentage below 85%, and the urgency
# (exit code 33) is set if there is less that 5% remaining.

use strict;
use warnings;
use utf8;

my $acpi;
my $status;
my $percent;
my $text;
my $time;

# read the first line of the "acpi" command output
open (ACPI, 'acpi -b |') or die "Can't exec acpi: $!\n";
$acpi = <ACPI>;
close(ACPI);

# fail on unexpected output
if ($acpi !~ /: (\w+), (\d+)%/) {
	die "$acpi\n";
}
$time = '';
$status = $1;
$percent = $2;
$text = "$percent%";

# Get time remaining
if ($acpi =~ /(\d\d:\d\d):/) {
	$time .= " ($1)";
}

# Get full text
if ($status eq 'Charging') {
	$text .= " $time\n$text\n";
}
else{
# consider color and urgent flag only on discharge
	# using Solarized colors
	if ($percent < 15) {
		$text .= "$time\n$text\n#dc322f\n";
	}
	elsif ($percent < 40) {
		$text .= "$time\n$text\n#cb4b16\n";
	}
	elsif ($percent < 60) {
		$text .= "$time\n$text\n#b58900\n";
	}
	elsif ($percent < 85) {
		$text .= "$time\n$text\n#85c000\n";
	}
	else{
		$text .= "$time\n$text";
	}
}

# Print text
print "$text";
if ($percent < 5 and $status eq 'Discharging') {
	exit(33);
}

exit(0);
