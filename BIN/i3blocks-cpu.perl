#!/usr/bin/env perl
#
# Copyright 2014 Pierre Mavro <deimos@deimos.fr>
# Copyright 2014 Vivien Didelot <vivien@didelot.org>
# Copyright 2014 Andreas Guldstrand <andreas.guldstrand@gmail.com>
#
# Licensed under the terms of the GNU GPL v3, or any later version.

use strict;
use warnings;
use utf8;
use Getopt::Long;

# default values
my $t_warn = 50;
my $t_crit = 80;
my $cpu_usage = -1;
my $button = 0;

sub help {
    print "Usage: cpu_usage [-w <warning>] [-c <critical>]\n";
    print "-w <percent>: warning threshold to become yellow\n";
    print "-c <percent>: critical threshold to become red\n";
    exit 0;
}

GetOptions("help|h"   => \&help,
           "w=i"      => \$t_warn,
           "c=i"      => \$t_crit,
		   "button=i" => \$button
	   );

# Get reply immediately
if($button == 3){
	`notify-send "CPU Usage" "\$(mpstat -P ALL | tail -n +3 | cut -c 14-16,18-24,26-32,34-40,42-48,50-56,58-64,90-97)" --icon indicator-cpufreq --app-name mpstat`;
}

# Get CPU usage
$ENV{LC_ALL}="en_US"; # if mpstat is not run under en_US locale, things may break, so make sure it is
open (MPSTAT, 'mpstat 1 1 |') or die;
while (<MPSTAT>) {
    if (/^Average:\s+all\s+(\d+\.\d+)\s+\d+\.\d+\s+(\d+\.\d+)/) {
        $cpu_usage = $1 + $2; # %usr + %sys
        last;
    }
}
close(MPSTAT);

$cpu_usage eq -1 and die 'Can\'t find CPU information';

# Print short_text, full_text
printf "%.2f%%\n", $cpu_usage;
printf "%.2f%%\n", $cpu_usage;

# Print color, if needed
if ($cpu_usage >= $t_crit) {
    print "#dc322f\n";
} elsif ($cpu_usage >= $t_warn) {
    print "#cccc00\n";
}

exit 0;
