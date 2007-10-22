#!/usr/bin/env perl
package Jifty::Plugin::OAuth::Model::RequestToken;
use strict;
use warnings;

use base qw( Jifty::Plugin::OAuth::Token Jifty::Record );

# kludge 1: you cannot call Jifty->app_class within schema {}
my $app_user;
BEGIN { $app_user = Jifty->app_class('Model', 'User') }

use Jifty::DBI::Schema;
use Jifty::Record schema {

    column valid_until =>
        type is 'timestamp',
        filters are 'Jifty::DBI::Filter::DateTime',
        is required;

    column authorized =>
        type is 'boolean',
        default is 'f';

    # kludge 2: this kind of plugin cannot yet casually refer_to app models
    column authorized_by =>
        type is 'integer';
        #refers_to $app_user;

    column consumer =>
        refers_to Jifty::Plugin::OAuth::Model::Consumer,
        is required;

    column used =>
        type is 'boolean',
        default is 'f';

    column token =>
        type is 'varchar',
        is required;

    column secret =>
        type is 'varchar',
        is required;

};

=head2 table

RequestTokens are stored in the table C<oauth_request_tokens>.

=cut

sub table {'oauth_request_tokens'}

=head2 after_set_authorized

This will set the C<authorized_by> to the current user.

=cut

sub after_set_authorized {
    my $self = shift;
    $self->set_authorized_by(Jifty->web->current_user->id);
}

=head2 can_trade_for_access_token

This neatly encapsulates the "is this request token perfect?" check.

This will return a (boolean, message) pair, with boolean indicating success
(true means the token is good) and message indicating error (or another
affirmation of success).

=cut

sub can_trade_for_access_token {
    my $self = shift;

    return (0, "Request token is not authorized")
        if !$self->authorized;

    return (0, "Request token does not have an authorizing user")
        if !$self->authorized_by;

    return (0, "Request token already used")
        if $self->used;

    return (0, "Request token expired")
        if $self->valid_until < DateTime->now;

    return (1, "Request token valid");
}

1;
