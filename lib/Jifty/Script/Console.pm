use strict;
use warnings;

package Jifty::Script::Console;
use base qw/Jifty::Script/;
use Devel::EvalContext;
use Term::ReadLine;

=head1 NAME

Jifty::Script::Console - A console for your Jifty application

=head1 SYNOPSIS

    jifty console
    jifty console --help
    jifty console --man

=head1 OPTIONS

This script has no specific options now except help.
Maybe it will have some command lines options in the future.

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

This script aims for developing purpose (or maintaining, if possible).
With this script, you can say something like this to diagnose your
application:

    % bin/jifty console
    jifty> my $foo = Jifty->app_class("Model", "StuffCollection")->new;
    jifty> $foo->unlimit; YAML::Dump($foo)

All Perl code are ok, since each lines of input are send to
C<eval()>.

=head1 METHODS

=head2 run

Creates a new console process.

=cut

sub run {
    my $self = shift;
    $self->print_help();
    Jifty->new();
    my $term = new Term::ReadLine 'Jifty Console';
    my $OUT = $term->OUT || \*STDOUT;
    my $cxt = Devel::EvalContext->new;
    while (defined($_ = $term->readline("jifty> "))) {
        if (/\S/) {
            my $res = $cxt->run($_);
            warn $@ if $@;
            print $OUT $res, "\n" unless $@ || !defined($res);
            $term->addhistory($_);
        }
    }
}

1;

=head1 AUTHOR

Kang-min Liu C<<gugod@gugod.org>>

=cut
