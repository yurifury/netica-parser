#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Dnet;

my $filename = 'Exam.dnet';
if (defined $ARGV[0]) {
    $filename = $ARGV[0];
}
my $dnet = Dnet->new();
$dnet->create_from_file($filename);
$dnet->gen_dot_partial('durp');
$dnet->gen_dot_topo('hurp');
#print Dumper $dnet;

#my %ordering = $dnet->create_ordered_hash();
#print "Node: Parents\n";
#print "-------------\n";
#foreach my $key (sort keys %ordering) {
    #print "$key:\n";
    #foreach my $x (@{$ordering{$key}}) {
        #print "  $x\n";
    #}
    #print "\n";
#}

#print "Nodes:\n";
#foreach my $root ($dnet->get_nodes()) {
    #print "  $root\n";
#}

#print "Roots:\n";
#foreach my $root ($dnet->list_roots()) {
    #print "  $root\n";
#}

#print "Leaves:\n";
#foreach my $root ($dnet->list_leaves()) {
    #print "  $root\n";
#}

#$dnet->partial_ordering();

