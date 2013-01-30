#!/usr/bin/env perl
use Modern::Perl;

# CPAN modules
use Data::Dump qw<dump>;
use Data::Printer;
use DateTime;
use JSON;
use Mojo::IOLoop;
use Mojolicious::Lite;
use Number::Format qw<:subs>;
use Try::Tiny;

# OANDA modules
use OANDA::Rates;

local $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

our $rates = OANDA::Rates->new( {host => 'house-rates.dev.oanda.com'} );

# Write the process ID to the .pid file
# (for the start/stop scripts)
try {
    my $fh = IO::File->new;
    $fh->open('> /oanda/var/fxcup/run/fxcup.pid');
    print $fh $$;
    $fh->close;
}
catch {
    die "Could not write the process ID to the .pid file";
};

my $j     = JSON->new;
my $clients = {};

our $event_loop = Mojo::IOLoop->recurring( 1 => sub {

    for ( keys %{ $clients } ) {
        $clients->{$_}->send(
            $j->encode(
                { timestamp => time, rates => $rates->current_rates }
            )
        );
    }
});

get '/' => sub {
    my $self = shift;
    $self->render( text => "root" );
};

# socket route for polling data for a particular league
websocket '/rates' => sub {
    my $self = shift;

    my $id = sprintf "%s", $self->tx;

    app->log->debug( sprintf( "Client connected: %s", $id ) );

    $clients->{$id} = $self->tx;

    $self->on(
        finish => sub {
            warn app->log->debug("Client disconnected: $id");
            delete $clients->{$id};
        }
    );
};

app->secret('cheesdiptastesgoodandisactuallyhealthyforyoudespiteanyevidencetothecontrary');
app->start;
