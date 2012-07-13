#!/usr/bin/env perl

use strict;
use warnings;

use Mojolicious::Lite;
use Mojo::IOLoop;

use ProtocolBufferMessages;
use Time::HiRes qw(time);
use OANDA::TORRID::Feed;
use OANDA::TORRID::RateSource;
use StreamSession;

my $torrid_host     = 'house-rates.dev.oanda.com';
my $torrid_cmd_port = 62013;

my $torrid_session = StreamSession->new(
    host  => $torrid_host,
    port  => $torrid_cmd_port,
    debug => 0
);
my $status = $torrid_session->subscribe( block => 1 );
my $banks = $torrid_session->_t_socket();

my $last_offers = {};

my $liquid_state     = {};
my $bank_socket      = tied *$banks;
my $last_bank_stamp  = 0;
my $last_oanda_stamp = 0;
my $bank_idle        = 1;
my $oanda_idle       = 1;
my $last_idle        = time();
my $last_render      = 0;

use DateTime;

websocket '/echo' => sub {
		my $self = shift;

		app->log->debug(sprintf 'Client connected: %s', $self->tx);
		my $id = sprintf "%s", $self->tx;

		$self->on(message =>
				sub {
						my ($self, $msg) = @_;

						my $json = Mojo::JSON->new;
						my $dt   = DateTime->now;

						while(<$banks>) {
								$last_bank_stamp = time();
								if ( $_->{tick}->{bank_tick} ) {
										#p $_->tick->bank_tick;

										#print "this is a bank tick: ".Dumper($_)."\n";
										my $bt = $_->{tick}->{bank_tick};

										my $i    = $bt->{instrument};
										my $bank = $bt->{rate_source};

										#print "setting instrument to $i and bank to $bank\n";
										$last_offers->{$i}->{$bank} = $bt;

										if ( $i eq "AUD/USD" ) {

												#print "AUD/USD: ".Dumper($bt)."\n";
										}

										if ( $bt->{suspect} ) {

												#print "tick suspect: ".Dumper($bt)."\n";
												$last_offers->{$i}->{$bank}->{normal_asks} = [];
												$last_offers->{$i}->{$bank}->{normal_bids} = [];
										}
										else {
												$last_offers->{$i}->{$bank}->{normal_asks} =
													[ normalize_bands( $bt, 'asks' ) ];
												$last_offers->{$i}->{$bank}->{normal_bids} =
													[ normalize_bands( $bt, 'bids' ) ];
										}

										#redraw($liquid_state);
										$self->send(
											$json->encode({
													hms  => $dt->hms,
													text => 'foo',
											})
										);
							}
						}
				}
		);

		$self->on(finish =>
				sub {
						app->log->debug('Client disconnected');
				}
		);
};

my %rates;

app->start;

sub band_to_string {
    my $b = shift;

   #print $b->{low_limit} . " to " . $b->{high_limit} . " @ " . $b->{price}.",";
    my $s =
      $b->{price} . " [" . $b->{low_limit} . ", " . $b->{high_limit} . "]";
    return $s

   #print $b->{low_limit} . " to " . $b->{high_limit} . " @ " . $b->{price}.",";
}

sub normalize_bands {

#Returns an array of bands in order of increasing cost (read: decreasing
#price tag for "bids", increasing price tags for "asks"), and with "poor value"
#prices discarded. (A band is conconsidered poor value if a large volume is available
#at a better price.)

    my $bt     = shift;
    my $bidask = shift;
    my @bands  = ();

    #TODO: move this constant elsewhere
    my %BIDASK_BETTER_PRICE = (
        asks => -1,    #lower is better
        bids => 1,     #higher is better
    );

    my $good_dir = $BIDASK_BETTER_PRICE{$bidask};

    if ( not defined( $bt->{$bidask} ) ) {

        #warn "bidask is empty in this bank tick: ". Dumper($bt)."\n";
        return @bands if not defined( $bt->{$bidask} );
    }

    my @raw_bands = @{ $bt->{$bidask} };

    @raw_bands =
      grep { not( ( $_->{low_limit} == 0 ) and ( $_->{high_limit} == 0 ) ) }
      @raw_bands;

    @raw_bands = sort {
        my $r = ( $a->{price} <=> $b->{price} ) * ( -1 * $good_dir );
        $r = $r or ( $a->{low_limit} <=> $b->{low_limit} );
        $r = $r or ( $a->{high_limit} <=> $b->{high_limit} );
        return $r;
    } @raw_bands;

    my $last;
    for my $band (@raw_bands) {
        if ( $last and ( $last->{high_limit} ne $band->{low_limit} ) ) {

            #I'm expecting most bands to line up with each other, except:
            #	- price regression (lower volume, more expensive): then discard
            if ( $last->{high_limit} < $band->{low_limit} ) {

                #pass -- it's fine to keep this
            }
            else {

                #discard?
                my $cmp = ( $last->{price} <=> $band->{price} );
                if ( $cmp == $good_dir ) {

#print "considering keeping ".band_to_string($last)." and discarding ".band_to_string($band)."\n";
                    next;
                }
                else {
                    print "wierd.. maybe I shouldn't keep "
                      . band_to_string($last)
                      . " and discard "
                      . band_to_string($band) . "\n";

                  #print "bidask_better_price is $good_dir for value $bidask\n";
                }
            }

#print "found out-of-order bands.  The previous was ".band_to_string($last)." and this one is ".band_to_string($band)."\n";
#print "The comparison that failed was between ".$last->{high_limit}." and ".$band->{low_limit}.".\n";
        }

        push @bands, $band;
        $last = $band;
    }

    return @bands;
}
