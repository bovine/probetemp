#!/usr/bin/perl

use strict;
use Device::SerialPort;

my $PortName = "/dev/ttyUSB0";

my $PortObj = new Device::SerialPort ($PortName)
    || die "Can't open $PortName: $!\n";

#$PortObj->baudrate(2400);
$PortObj->baudrate(9600);
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
#$PortObj->write("\r\n");


    $buffer .= $PortObj->read(255);
    print "got \"$buffer\"\n";
    while ($buffer =~ s/^(.*?)[\n\r]+//s) {
	my $line = $1;
	my $timestamp = time();
	$linesread++;

	if ($line =~ m/^([1234])\s+(\-?[\d\.]+)/) {
	    my ($sensor, $degrees) = ($1, $2);
	    $lastread{$sensor}{'degrees'} = $degrees;
	    $lastread{$sensor}{'timestamp'} = $timestamp;
	} else {
	    print "$timestamp: Ignoring line \"$line\"\n";
	}
    }
    last if ($linesread >= 9 && scalar(keys(%lastread)));
}

foreach my $id (keys(%lastread)) {
    print "got ". $lastread{$id}{'timestamp'} . "," . $id . "," . $lastread{$id}{'degrees'} . "\n";
}

exit 0;
