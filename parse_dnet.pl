#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Dnet;
use JSON -convert_blessed_universally;

my $filename = $ARGV[0];
print "Usage: perl parse_dnet.pl dnet_filename" and die unless defined $filename;

# Create a new Dnet object, which is our parser
my $dnet = Dnet->new();

# Parse the file
$dnet->create_from_file($filename);

# Spit out the partial representation in .dot
$dnet->gen_dot_partial('partial.dot');

# Spit out the other data in .json
# add ->pretty(1) for compact output
# pretty output: JSON->new->pretty(1)->convert_blessed->encode($dnet);
open my $json_file, '>', 'parsed_dnet.json';
print $json_file JSON->new->pretty(1)->convert_blessed->encode($dnet);
close $json_file;
