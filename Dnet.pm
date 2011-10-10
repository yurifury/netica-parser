package Dnet;

use warnings;
use strict;
use Data::Dumper;
use Storable qw(dclone); # To deeply copy data structures

# Ctor
sub new {
    my $self = {};
    bless $self;
    return $self;
}

sub parse {
    my $self = shift;

    my $in_node = 0;

    foreach (@_) {
        # If we've found a node, make a new node in dnet
        # Also get ready to pull this node's attributes
        if (/node (\S+)/) {
            my $node_name = $1;
            $in_node = $1;
            $self->{nodes}->{$1} = {};
        }
        # We're in the attributes of a node
        if ($in_node) {
            # Fields to ignore
            next if /comment|whenchanged|center|height/;
            # Parse a single key/value
            if (/(\S+) = (\S+)/) {
                $self->{nodes}->{$in_node}->{$1} = $2;
            }
            # Parse a list
            if (/(\S+) = (\((?:\S?,?\s*)+\))/) {
                #my @list = split /,/, $2;
                my $list = $self->parse_list($2);
                $self->{nodes}->{$in_node}->{$1} = $list;
            }
        }
        # Set the name of the BN when we've found it
        if (/bnet (\S+)/) {
            $self->{meta}->{name} = $1;
        }
    }
    
    
    
    $self->{meta}->{nodes} = [];
    foreach my $node (sort keys %{$self->{nodes}}) {
        push @{$self->{meta}->{nodes}}, $node;
    }

    $self->{meta}->{roots} = [];
    foreach my $node (@{$self->{meta}->{nodes}}) {
        if (defined $self->{nodes}->{$node}->{parents}
                and @{$self->{nodes}->{$node}->{parents}} == 0) {
            push @{$self->{meta}->{roots}}, $node;
        }
    }

    $self->{meta}->{ordering} = {};
    foreach my $node (@{$self->{meta}->{nodes}}) {
        if (defined $self->{nodes}->{$node}->{parents}) {
            foreach my $parent (@{$self->{nodes}->{$node}->{parents}}) {
                push @{$self->{meta}->{ordering}->{$node}}, $parent;
            }
        }
    }

    my %leaves = map {$_ => 1} @{$self->{meta}->{nodes}};
    foreach my $node (@{$self->{meta}->{nodes}}) {
        foreach my $parent (@{$self->{meta}->{ordering}->{$node}}) {
            delete $leaves{$parent} if defined $leaves{$parent};
        }
    }
    @{$self->{meta}->{leaves}} = keys %leaves;

    %{$self->{meta}->{partial}} = map { $_ => [undef] } @{$self->{meta}->{leaves}};
    foreach my $node (@{$self->{meta}->{nodes}}) {
        foreach my $parent (@{$self->{meta}->{ordering}->{$node}}) {
            push @{$self->{meta}->{partial}->{$parent}}, $node;
        }
    }

}

sub parse_list {
    my $self = shift;
    my $list = shift;

    $list =~ s/^,//g;
    $list =~ s/\s//g;

    $list =~ s/([\w.]+)/"$1"/g;

    $list =~ s/\(/[/g;
    $list =~ s/\)/]/g;

    my $parsed_list = eval $list;
    return $parsed_list;
}

sub create_from_file {
    my $self = shift;
    my $filename = shift;

    my @contents; { 
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

    $self->parse(@contents);
}

sub gen_dot_partial {
    my $self = shift;
    my $filename = shift;

    open my $dot_file, ">", $filename;

    my $header = << "END";
digraph $self->{meta}->{name} {
    rankdir=TB;
END

    my $footer = '}';

    print $dot_file $header;
    foreach my $node (sort keys %{$self->{meta}->{partial}}) {
        foreach my $parent (@{$self->{meta}->{partial}->{$node}}) {
            print $dot_file "    $node -> $parent\n" if defined $parent;
        }
    }
    print $dot_file $footer;
}



1;
