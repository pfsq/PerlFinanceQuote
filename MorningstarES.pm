package Finance::Quote::MorningstarES;
require 5.004;

use strict;

use vars qw( $MORNINGSTAR_ES_FUNDS_URL);

use LWP::RobotUA;
use HTTP::Request::Common;
use HTML::TableExtract;

our $VERSION = '1.47'; # VERSION
$MORNINGSTAR_ES_FUNDS_URL = 'http://morningstar.es/es/funds/snapshot/snapshot.aspx?id=';

sub methods { return (morningstares => \&morningstares); }

{
  my @labels = qw/date isodate method source name currency nav/;

  sub labels { return (morningstares => \@labels ); }
}

sub morningstares {
  my $quoter  = shift;
  my @symbols = @_;

  return unless @symbols;
  my ($ua, $reply, $url, %funds, $te, $table, $row, @value_currency, $name);

  #$ua = LWP::RobotUA->new('gnc/0.2', 'gnc@zippymail.info');
  #$ua->agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36");

  foreach my $symbol (@symbols) {
    $name = $symbol;
    $url = $MORNINGSTAR_ES_FUNDS_URL;
    $url = $url . $name;
    $ua    = $quoter->user_agent;
    #$ua->delay((int(rand(6)) + 2)/60);
    $reply = $ua->request(GET $url);
    unless ($reply->is_success) {
	  foreach my $symbol (@symbols) {
        $funds{$symbol, "success"}  = 0;
        $funds{$symbol, "errormsg"} = "HTTP failure";
	  }
	  return wantarray ? %funds : \%funds;
    }

    $te = HTML::TableExtract->new();
    $te->parse($reply->decoded_content);
    #print "Tables: " . $te->tables_report() . "\n";
    for my $table ($te->tables()) {
        for my $row ($table->rows()) {
            if (defined(@$row[0])) {
                if ('VL' eq substr(@$row[0],0,2)) {
                    # print "@${row[0]}\n";
                    my $date = substr(@$row[0],-10);
                    @value_currency = split(' ', $$row[2]);
                    $funds{$name, 'method'}   = 'morningstar_funds';
                    $value_currency[1] =~ s/,/\./;
                    $funds{$name, 'nav'}    = $value_currency[1];
                    $funds{$name, 'currency'} = $value_currency[0];
                    $funds{$name, 'success'}  = 1;
                    $funds{$name, 'symbol'}  = $name;
                    $quoter->store_date(\%funds, $name, {eurodate => $date});
                    $funds{$name, 'source'}   = 'Finance::Quote::MorningstarES';
                    $funds{$name, 'name'}   = $name;
                    $funds{$name, 'p_change'} = "";  # p_change is not retrieved (yet?)
                } elsif ('Bid' eq substr(@$row[0],0,3)) {
                    # print "@${row[0]}\n";
                    # my $date = substr(@$row[0],-30,10);
                    (my $date) = @$row[0] =~ m/(\d+\/\d+\/\d+)/g;
                    # print "${date}\n";
                    @value_currency = split(' ', $$row[2]);
                    $funds{$name, 'method'}   = 'morningstar_funds';
                    $value_currency[1] =~ s/,/\./;
                    $funds{$name, 'nav'}    = $value_currency[1];
                    $funds{$name, 'currency'} = $value_currency[0];
                    $funds{$name, 'success'}  = 1;
                    $funds{$name, 'symbol'}  = $name;
                    $quoter->store_date(\%funds, $name, {eurodate => $date});
                    $funds{$name, 'source'}   = 'Finance::Quote::MorningstarES';
                    $funds{$name, 'name'}   = $name;
                    $funds{$name, 'p_change'} = "";  # p_change is not retrieved (yet?)
                }
            }
        }
    }

    # Check for undefined symbols
    foreach my $symbol (@symbols) {
	  unless ($funds{$symbol, 'success'}) {
        $funds{$symbol, "success"}  = 0;
        $funds{$symbol, "errormsg"} = "Fund name not found";
	  }
    }
  }
  return %funds if wantarray;
  return \%funds;
}

1;

=head1 NAME

Finance::Quote::Morningstar - Obtain fund prices the Fredrik way

=head1 SYNOPSIS

    use Finance::Quote;

    $q = Finance::Quote->new;

    %fundinfo = $q->fetch("morningstar","fund name");

=head1 DESCRIPTION

This module obtains information about Fredrik fund prices from
www.morningstar.es.

=head1 FUND NAMES

Use some smart fund name...

=head1 LABELS RETURNED

Information available from Fredrik funds may include the following labels:
date method source name currency price. The prices are updated at the
end of each bank day.

=head1 SEE ALSO

Perhaps morningstar?

=cut
