#!/usr/bin/perl

use strict;
use RRDs;
use Device::SerialPort;

my $PortName = "/dev/ttyS0";

my $PortObj = new Device::SerialPort ($PortName)
    || die "Can't open $PortName: $!\n";

$PortObj->baudrate(2400);
$PortObj->parity("none");
$PortObj->databits(8);
$PortObj->stopbits(1);
$PortObj->read_const_time(500);       # 500 milliseconds = 0.5 seconds
$PortObj->read_char_time(0);          # avg time between read char

# abort if we haven't finished after 30 seconds.
local $SIG{'ALRM'} = sub { die "alarm\n" };
alarm 30;

my $buffer = '';
my %lastread;
my $linesread = 0;
while (1) {
    $buffer .= $PortObj->read(255);
    while ($buffer =~ s/^(.*?)[\n\r]+//s) {
	my $line = $1;
	my $timestamp = time();
	$linesread++;

	if ($line =~ m/^(\d)\s+([\d\.]+)/) {
	    my ($sensor, $degrees) = ($1, $2);
	    $lastread{$sensor}{'degrees'} = $degrees;
	    $lastread{$sensor}{'timestamp'} = $timestamp;
	} else {
	    #print "$timestamp: Got line \"$1\"\n";
	}
    }
    if ($linesread >= 9 && defined($lastread{1}) && defined($lastread{2})) {
	# Write to a CSV file.
	open(FILE, ">>probetemp.txt") || die "failed to open log file";
	foreach my $id (keys(%lastread)) {
	    print FILE $lastread{$id}{'timestamp'} . "," . $id . "," . $lastread{$id}{'degrees'} . "\n";
	}
	close(FILE);

	# Save to RRD database.
	my @template;
	my @valuelist;
	foreach my $id (keys(%lastread)) {
	    push(@template, "id$id");
	    push(@valuelist, $lastread{$id}{'degrees'});
	}
	RRDs::update ("probetemp.rrd", "--template", join(':', @template),
		      "N:" . join(':', @valuelist))
	    or warn "failed to update RRD";
	last;
    }
}
