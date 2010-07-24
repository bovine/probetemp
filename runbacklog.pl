#!/usr/bin/perl

use RRDs;
use strict;

my $rrdfile = 'probetemp.rrd';

if ($ARGV[0]) {
    $rrdfile = $ARGV[0];
}

if (!-f $rrdfile) {
    print "Creating new database.\n";
    system("rrdtool create $rrdfile -b 1127636956 --step 300 DS:id1:GAUGE:600:-50:100 DS:id2:GAUGE:600:-50:100 DS:id3:GAUGE:600:-50:100 DS:id4:GAUGE:600:-50:100 RRA:AVERAGE:0.5:1:1200 RRA:MIN:0.5:12:2400 RRA:MAX:0.5:12:2400 RRA:AVERAGE:0.5:12:2400");
}

my $lasttime = 0;
my %lastvalues;
while (<STDIN>) {
    chomp;
    my ($timestamp, $id, $degrees) = split(',');
    if ($timestamp < $lasttime) {
	print "Rejecting decreasing timestamp $timestamp < $lasttime.\n";
	next;
    } elsif ($timestamp == $lasttime) {
	$lastvalues{$id} = $degrees;
    } else {
	#print ".";
	# store what we have in the cache.
	my @template;
	my @valuelist;
	foreach my $a (sort(keys(%lastvalues))) {
	    push(@template, "id$a");
	    push(@valuelist, $lastvalues{$a});
	}
	if (scalar(@template)) {
	    #my $cmdline = "rrdupdate $rrdfile --template " . join(':', @template) . 
	    #" $timestamp:" . join(':', @valuelist);
	    #system($cmdline) && print "cmdline was: $cmdline\n";
	    
	    RRDs::update ($rrdfile, "--template", join(':', @template), 
			  "$lasttime:" . join(':', @valuelist))
		or warn "failed to update $lasttime";
	}

	# restart the cache again.
	$lasttime = $timestamp;
	%lastvalues = ( $id => $degrees );
    }
}
