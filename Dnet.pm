package Dnet;

use warnings;
use strict;
use Data::Dumper;

sub new {
    my $self = {};
    bless $self;
    return $self;
}

#sub get_nodes {
    #my $self = shift;

#}

#sub list_leaves {
    #my $self = shift;

    #my %leaves = %nodes;
    #foreach my $node (sort keys %nodes) {
        #foreach my $parent (@{$order_nodes{$node}}) {
            #delete $leaves{$parent} if defined $leaves{$parent};
        #}
    #}
    #return keys %leaves;
#}

#sub list_roots {
    #my $self = shift;
    #my @roots = ();
    #foreach my $node (sort keys %{$self}) {
        #next if $node =~ /^_/;
        #if (defined $self->{$node}->{parents}
                #and @{$self->{$node}->{parents}} == 0) {
            #push @roots, $node;
        #}
    #}
    #@root_nodes = @roots;
    #return @roots;
#}

#sub create_ordered_hash {
    #my $self = shift;

    #my %ordering = ();
    #foreach my $node (sort keys %{$self}) {
        #next if $node =~ /^_/;
        #if (defined $self->{$node}->{parents}) {
            #foreach my $parent (@{$self->{$node}->{parents}}) {
                #push @{$ordering{$node}}, $parent;
                ##print "${node}'s parent is $parent\n";
            #}
        #}
    #}
    #%order_nodes = %ordering;
    #return %ordering;
#}

#sub partial_ordering {
    #my $self = shift;

    #unless (@root_nodes and %order_nodes) {
        #$self->create_ordered_hash();
        #$self->list_roots();
    #}

    #my %partial = ();

    #%partial = map {$_ => undef } keys %leaves;

    #print "\nPartial ordering:\n";
    #foreach my $key (sort keys %partial) {
        #$partial{$key} = 'undef' unless defined $partial{$key};
        #print "$key => $partial{$key}\n";
    #}


#}

sub parse {
    my $self = shift;

    my $in_node = 0;

    foreach (@_) {
        # If we've found a node, make a new node in dnet
        # Also get ready to pull this node's attributes
        if (/node (\S+)/) {
            my $node_name = $1;
            $in_node = $1;
            $self->{$1} = {};
        }
        # We're in the attributes of a node
        if ($in_node) {
            # Fields to ignore
            next if /comment|whenchanged|center|height/;
            # Parse a single key/value
            if (/(\S+) = (\S+)/) {
                $self->{$in_node}->{$1} = $2;
            }
            # Parse a list
            if (/(\S+) = (\((?:\S?,?\s*)+\))/) {
                #my @list = split /,/, $2;
                my $list = $self->parse_list($2);
                #print Dumper @list;
                $self->{$in_node}->{$1} = $list;
            }
        }
        # Set the name of the BN when we've found it
        if (/bnet (\S+)/) {
            $self->{_name} = $1;
        }
    }
    
    $self->{_nodes} = [];
    foreach my $node (sort keys %{$self}) {
        next if $node =~ /^_/;
        push @{$self->{_nodes}}, $node;
    }

    $self->{_roots} = [];
    foreach my $node (@{$self->{_nodes}}) {
        if (defined $self->{$node}->{parents}
                and @{$self->{$node}->{parents}} == 0) {
            push @{$self->{_roots}}, $node;
        }
    }

    $self->{_ordering} = {};
    foreach my $node (@{$self->{_nodes}}) {
        if (defined $self->{$node}->{parents}) {
            foreach my $parent (@{$self->{$node}->{parents}}) {
                push @{$self->{_ordering}->{$node}}, $parent;
            }
        }
    }

    #%partial = map {$_ => undef } keys %leaves;
    my %leaves = map {$_ => 1} @{$self->{_nodes}};
    foreach my $node (@{$self->{_nodes}}) {
        foreach my $parent (@{$self->{_ordering}->{$node}}) {
            delete $leaves{$parent} if defined $leaves{$parent};
        }
    }

    @{$self->{_leaves}} = keys %leaves;
    #foreach my $x (@{$self->{_roots}}) {
        #print "$x\n";
        ## body...
    #}

#my %nodes;
#my @root_nodes;
#my %order_nodes;
#my %leaves;

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
    #print Dumper $parsed_list;
    return $parsed_list;
}

sub create_from_file {
    my $self = shift;
    my $filename = shift;

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


    $self->parse(@contents);
}

1;
