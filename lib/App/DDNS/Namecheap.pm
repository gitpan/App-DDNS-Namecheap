package App::DDNS::Namecheap;
{
  $App::DDNS::Namecheap::VERSION = '0.012';
}

use Moose;
use LWP::Simple qw($ua get);
$ua->agent("");
use Mozilla::CA;

has domain => ( is => 'ro', isa => 'Str', required => 1 );
has password => ( is => 'ro', isa => 'Str', required => 1 );
has hosts => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has ip => ( is => 'rw', isa => 'Str', builder => 'external_ip' );

sub update {
  my $self = shift;
  unless ( $self->{ip} eq 0 ) {
    foreach ( @{ $self->{hosts} } ) {
      my $url = "https://dynamicdns.park-your-domain.com/update?host=$_&domain=$self->{domain}&password=$self->{password}&ip=$self->{ip}";
      if ( my $return = get($url) ) {
        $self->log("$0: $return") unless $return =~ /<errcount>0<\/errcount>/is;
      }
    }
  }
}

sub external_ip {
  my $self = shift;
  my $ip = get("http://icanhazip.com") || 0;
  $ip = ( $ip =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/ ? $1 : 0 );
  $self->log("$0: failed to get external ip") if $ip eq 0;
  return $ip;
}

sub log { shift; print @_, "\n" }

no Moose;

1;

__END__

=head1 NAME

App::DDNS::Namecheap - Dynamic DNS update utility for Namecheap registered domains

=head1 VERSION

version 0.012

=head1 SYNOPSIS

    my $domain =  App::DDNS::Namecheap->new(
                      domain   => 'mysite.org',
         	      password => 'abcdefghijklmnopqrstuvwxyz012345',
		      hosts    => [ "@", "www", "*" ],
		      ip       => '127.0.0.1',      #defaults to external ip
    );

    $domain->update();

=head1 DESCRIPTION

This module provides a method for setting the address records of your Namecheap registered 
domains to your external IP address. 

=head1 METHODS

=over 4

=item B<update>

Updates Namecheap A records using the four attributes listed above.

=item B<external_ip>

Pulls external ip using a public service.

=item B<log>

Logs output to stderr.

=back

=head1 CAVEATS

Tested under darwin only.

=head1 AUTHOR

David Watson <dwatson@cpan.org>

=head1 SEE ALSO

scripts/ in the distribution

=head1 COPYRIGHT AND LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included with this module.

=cut
