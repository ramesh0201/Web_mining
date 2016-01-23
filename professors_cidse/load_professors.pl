use XML::Hash;
use Data::Dumper;
use DBI;
my $xml_converter = XML::Hash->new();

open(FILE,'professorcidse.xml');
my $xml = <FILE>;
close(FILE);
# Convertion from a XML String to a Hash
my $xml_hash = $xml_converter->fromXMLStringtoHash($xml);

my $i = 0;
my @profarray = @{$xml_hash->{'professors'}->{'professor'}};
my $dbh = DBI->connect('dbi:mysql:test','root','root') or die "Connection Error: $DBI::errstr\n";
my $insert_query = "INSERT INTO test.Professors(id, name, cidseurl, customurl, interests) values(?,?,?,?,?)";
my $sth = $dbh->prepare( $insert_query );
foreach my $element(@profarray) {
	my $customurl = '';
	my $interest = '';
	if ($element->{'customurls'}) {
		if (ref($element->{'customurls'}->{'customurl'}) eq 'HASH') {
			$customurl = $element->{'customurls'}->{'customurl'}->{'text'};
		}
		elsif (ref($element->{'customurls'}->{'customurl'}) eq 'ARRAY') {
			my @customurls = ();
			@customurls = map { $_->{'text'} } @{$element->{'customurls'}->{'customurl'}};
			$customurl = join(',', @customurls);
		}
	}
	if ($element->{'interests'}) {
		if (ref($element->{'interests'}->{'interest'}) eq 'HASH') {
			$interest = $element->{'interests'}->{'interest'}->{'text'};
		}
		elsif (ref($element->{'interests'}->{'interest'}) eq 'ARRAY') {
			my @interests = ();
			@interests = map { $_->{'text'} } @{$element->{'interests'}->{'interest'}};
			$interest = join(',', @interests);
		}
	}
	$sth->execute($element->{'id'}, $element->{'name'}->{'text'}, $element->{'cidseurl'}->{'text'}, $customurl, $interest);
	$i++;
}
print "$i records inserted in professor table\n";