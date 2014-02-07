#!/usr/bin/env perl
#
# Description: A simple dotfile installer with minimal dependencies
#
use v5.10;
use strict;
use warnings;
use File::Basename;
use File::Spec;

my $target = $ARGV[0] // $ENV{HOME};

my %excludes = map { $_ => 1} basename($0), qw(.git .gitmodules);

my $mappings = {
};

my @src = grep { !/sw[op]$/ && !$excludes{$_} }
    keys %{{
        map { $_ => 1 } keys($mappings),  get_sources(dirname($0))
    }};

foreach my $source (@src) {
    if ($mappings->{$source}) {
        # custom deployment
    } else {
        deploy($source, $target);
    }
}


sub get_sources {
    my $dir = shift;
    opendir my $dh, $dir or die "'$dir': $!";
    my @entries = grep { !/^\.\.?$/ } readdir($dh);
    closedir $dh;
    return @entries;
}

sub deploy {
    my ($source, $target) = @_;
    my $target_path = File::Spec->catfile($target, $source);
    if (symlink $source, $target_path) {
        printf "+ $target_path .... OK\n";
    } else {
        warn "skipping '$target_path': $!\n";
    }
}

__END__

=head1 NAME

deploy.pl

=head1 SYNOPSIS

deploy.pl [dir]

=head1 DESCRIPTION

Symlinks all the files in this dierctory into the users C<$HOME>, (or
alternate target directory)

Excludes some files by default

=head1 CAVEATS

=over 4

=item *

Has minimal dependencies, just standard perl (5.10+)

=item *

Not very configurable. Probably doesn't need to be

=back

=head1 AUTHOR

Simon Flack

=cut
