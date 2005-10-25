#!/usr/bin/perl

use RRDs;
use strict;

if (!-f "probetemp.rrd") {
    print "Creating new database.\n";
    system("rrdtool create probetemp.rrd -b 1127636956 --step 300 DS:id1:GAUGE:600:-50:100 DS:id2:GAUGE:600:-50:100 DS:id3:GAUGE:600:-50:100 DS:id4:GAUGE:600:-50:100 RRA:AVERAGE:0.5:1:1200 RRA:MIN:0.5:12:2400 RRA:MAX:0.5:12:2400 RRA:AVERAGE:0.5:12:2400");
}

open(FILE, "probetemp3.txt") || die;
my $lasttime = 0;
my %lastvalues;
while (<FILE>) {
    chomp;
    my ($timestamp, $id, $degrees) = split(',');
    if ($timestamp < $lasttime) {
	print "Rejecting decreasing timestamp.\n";
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
	    #my $cmdline = "rrdupdate probetemp.rrd --template " . join(':', @template) . 
	    #" $timestamp:" . join(':', @valuelist);
	    #system($cmdline) && print "cmdline was: $cmdline\n";
	    
	    RRDs::update ("probetemp.rrd", "--template", join(':', @template), 
			  "$lasttime:" . join(':', @valuelist))
		or warn "failed to update $lasttime";
	}

	# restart the cache again.
	$lasttime = $timestamp;
	%lastvalues = ( $id => $degrees );
    }
}
