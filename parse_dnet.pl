#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Dnet;

my $dnet = Dnet->new();
my $in_node = 0;

while (<>) {
    if ($in_node) {
        if (/(\w+) = (\w+);/) {
            $dnet->{$in_node}->{$1} = $2;
        }
        if (/(\w+) = \(([\w, ]+)\);/) {
            my @list = split /,/, $2;
            s/[ ']//g for @list;
            $dnet->{$in_node}->{$1} = [@list];
        }
    }
    if (/bnet (\w+)/) {
        $dnet->{_name} = $1;
    }
    if (/node (\w+)/) {
        my $node_name = $1;
        $in_node = $1;
        $dnet->{$1} = {};
    }
}

print Dumper $dnet;
