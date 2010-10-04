#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Dnet;

my @contents;
{ 
    local $/ = "\n";
    local *FILE;
    open FILE, "<Exam.dnet";
    @contents = <FILE>;
    close FILE 
}

map { 
    s/\/\/.*$//g;
    } @contents;

my $file = join "", @contents;
@contents = split /[;{}]/, $file;
@contents = grep { !/^\s*$/ } @contents;
map { 
    s/\/\/.*$//g;
    s/\s+/ /g;
    s/\s*$//g;
    s/^\s*//g;
    } @contents;
#print Dumper @contents;


my $dnet = Dnet->new();
my $in_node = 0;

for (@contents) {
    if ($in_node) {
        if (/(\w+) = (\w+)/) {
            $dnet->{$in_node}->{$1} = $2;
        }
        if (/(\S+) = \(((?:\S?,?\s*)+)\)/) {
            my @list = split /,/, $2;
            s/\s//g for @list;
            #print Dumper @list;
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

#print Dumper $dnet;

print Dumper $dnet->list_priors();
