#!/usr/bin/perl

use strict;
use RRDs;
use Device::SerialPort;

if (scalar(@ARGV) != 1) {
    die "Port device not specified on command-line."
}
my $PortName = shift(@ARGV);

my $PortObj = new Device::SerialPort ($PortName)
    || die "Can't open $PortName: $!\n";

$PortObj->baudrate(2400) || warn "baudrate";
$PortObj->parity("none") || warn "parity";
$PortObj->databits(8) || warn "databits";
$PortObj->stopbits(1) || warn "stopbits";
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
    #print "got $buffer\n";
    while ($buffer =~ s/^(.*?)[\n\r]+//s) {
	my $line = $1;
	#print "got \"$line\"\n";
	my $timestamp = time();
	$linesread++;

	if ($line =~ m/^([1234])\s+(\-?[\d\.]+)/) {
	    my ($sensor, $degrees) = ($1, $2);
	    $lastread{$sensor}{'degrees'} = $degrees;
	    $lastread{$sensor}{'timestamp'} = $timestamp;
	} else {
	    #print "$timestamp: Ignoring line \"$line\"\n";
	}
    }
    last if ($linesread >= 9 && scalar(keys(%lastread)));
}

# Write to a CSV file.
open(FILE, ">>probetemp.txt") || die "failed to open log file";
foreach my $id (keys(%lastread)) {
    print FILE $lastread{$id}{'timestamp'} . "," . $id . "," . $lastread{$id}{'degrees'} . "\n";
    #print "got ". $lastread{$id}{'timestamp'} . "," . $id . "," . $lastread{$id}{'degrees'} . "\n";
}
close(FILE);

# Save to RRD database.
{
    my @template;
    my @valuelist;
    foreach my $id (keys(%lastread)) {
	push(@template, "id$id");
	push(@valuelist, $lastread{$id}{'degrees'});
    }
    RRDs::update ("probetemp.rrd", "--template", join(':', @template),
		  "N:" . join(':', @valuelist))
	or warn "failed to update RRD";
}

exit 0;
