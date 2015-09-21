#!/usr/bin/perl

#  generate.sh
#  WebServiceProtocol
#
#  Created by Nate Petersen on 8/30/15.
#  Copyright (c) 2015 Digital Rickshaw. All rights reserved.

use strict;
use warnings;
use JSON::PP;

my $infilename = shift;
my $outdir = shift;

print "Parsing file: ${infilename}\n";

open(FILEIN, $infilename) or die "Can't open $infilename: $!";
my $string = join("", <FILEIN>); 
close FILEIN;

# print "File:\n${string}";

if ($string =~ m/\@protocol ([a-zA-Z0-9_]*) <DRWebService>/ ) {
	print "Protocol: ${1}\n";

	my $outfilename = "${outdir}/${1}.drproto";
	print "Output file name: ${outfilename}\n";

	my %annoMap = ();

	while($string =~ m/(@[a-zA-Z]*\([\S\s]*?;)\n/g ) {
		my @lines = split /^/, $1;
		my $numLines = @lines;
		my %annotations = ();

		for (my $i=0; $i < $numLines - 1; $i++) {
			my $line = $lines[$i];

			print "Working on ${line}\n";

			if ($line =~ m/@([a-zA-Z]*)\(\"(.*)\"\)/g) {
				print "Got annotation, ${1} : ${2}\n";
				$annotations{$1} = $2;
			}
		}

		print "Collected annotations:@{[%annotations]}\n";

		my $methodString = $lines[$numLines - 1];

		print "Working on method string: ${methodString}\n";

		my $methodSig = "";

		while ($methodString =~ m/.*?\(.*?\).*?([a-zA-Z0-9_]+)[\s]*:/g) {
			$methodSig = $methodSig . $1 . ":";
		}

		if (length($methodSig) == 0) {
			if ($methodString =~ m/.*\(.*\)([a-zA-Z0-9_]+)[\s]*;/g) {
				$methodSig = $1;
			}
		}

		print "Found method sig: ${methodSig}\n";

		my %methodDesc = ();

		$methodDesc{"annotations"} = \%annotations;

		print "Working on param names\n";

		my @params = ();

		while ($methodString =~ m/:[\s]*\([^)]*\)[\s]*([a-zA-Z0-9_]+)/g) {
			push @params, $1;
		}

		$methodDesc{"parameterNames"} = \@params;

		print "working on task type\n";
		
		if ($methodString =~ m/-[\s]*\(([^)]*)\)/g) {
			$methodDesc{"taskType"} = $1;
		}
		
		print "working on callback type\n";

		if ($methodString =~ m/DR_CALLBACK\(([^)]+)\)/g) {
			$methodDesc{"resultType"} = $1;
		}

		$annoMap{$methodSig} = \%methodDesc;
	}

	open(FILEOUT, ">$outfilename") or die "Can't write to $outfilename: $!";

	print "final map:@{[%annoMap]}\n";
	my $jsonstring = encode_json \%annoMap;
	print FILEOUT $jsonstring;

	close FILEOUT;
}