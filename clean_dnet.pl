#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Dnet;

my $filename = 'Exam.dnet';
if (defined $ARGV[0]) {
    $filename = $ARGV[0];
}
    
my @contents;
{ 
    local $/ = "\n";
    local *FILE;
    open FILE, "<", $filename;
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

#print Dumper $dnet;
my $dnet = Dnet->new();
my $in_node = 0;

foreach my $x (@contents) {
    #print "$x\n\n";
}

for (@contents) {
    # If we've found a node, make a new node in dnet
    # Also get ready to pull this node's attributes
    if (/node (\w+)/) {
        my $node_name = $1;
        $in_node = $1;
        $dnet->{$1} = {};
    }
    # We're in the attributes of a node
    if ($in_node) {
        # Fields to ignore
        next if /whenchanged|center|height/;
        # Parse a single key/value
        if (/(\w+) = (\w+)/) {
            $dnet->{$in_node}->{$1} = $2;
        }
        # Parse a list
        if (/(\S+) = (\((?:\S?,?\s*)+\))/) {
            #my @list = split /,/, $2;
            my $list = parse_list($2);
            #print Dumper @list;
            $dnet->{$in_node}->{$1} = $list;
        }
    }
    # Set the name of the BN when we've found it
    if (/bnet (\w+)/) {
        $dnet->{_name} = $1;
    }
}
print Dumper $dnet;

my %ordering = $dnet->create_ordered_hash();
print "Node: Parents\n";
print "-------------\n";
foreach my $key (sort keys %ordering) {
    print "$key:\n";
    foreach my $x (@{$ordering{$key}}) {
        print "  $x\n";
        # body...
    }
    print "\n";
}

print "Priors:\n";
foreach my $prior ($dnet->list_priors()) {
    print "  $prior\n";
}
#print Dumper $dnet->list_priors();

sub parse_list {
    my $list = shift;

    $list =~ s/^,//g;
    $list =~ s/\s//g;

    $list =~ s/(\w+)/"$1"/g;

    $list =~ s/\(/[/g;
    $list =~ s/\)/]/g;

    my $parsed_list = eval $list;
    #print Dumper $parsed_list;
    return $parsed_list;
}
