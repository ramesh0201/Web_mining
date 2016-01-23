use JSON::Parse 'parse_json';
use DBI;
use Data::Dumper;

my $json;
open (FILE,'profiledata.json');
$json = <FILE>;
close(FILE);
my $profiles = parse_json ($json);

my $dbh = DBI->connect('dbi:mysql:test','root','root') or die "Connection Error: $DBI::errstr\n";
my $insert_query_profile = "insert into test.linkedinprofile(id, recruitingid, name, summary) values(?,?,?,?)";
my $insert_query_company = "insert into test.linkedincompany(id, linkedinprofileid, daterange, duration, location, role, company) values(?,?,?,?,?,?,?)";
my $insert_query_education = "insert into test.linkedineducation(id, linkedinprofileid, institute, daterange, degree) values(?,?,?,?,?)";
my $insert_query_skill = "insert into test.linkedinskill(id, linkedinprofileid, skill) values(?,?,?)";
my $insert_query_interest = "insert into test.linkedininterest(id, linkedinprofileid, interest) values(?,?,?)";
my $sth = $dbh->prepare( $insert_query_profile );
my $rth = $dbh->prepare( $insert_query_company );
my $qth = $dbh->prepare( $insert_query_education );
my $uth = $dbh->prepare( $insert_query_skill );
my $vth = $dbh->prepare( $insert_query_interest );
my $i = 1;
my $j = 1;
my $k = 1;
my $m = 1;
my $n = 1;
foreach my $profile(@$profiles) {
	$sth->execute($i, $profile->{'recuitingId'}, $profile->{'name'}, $profile->{'summary'});
	my @experiences = @{$profile->{'experience'}};
	if (scalar @experiences) {
		foreach my $experience (@experiences) {
			$experience->{'daterange'} =~ /(.*)<span class=\"duration\">(.*)<\/span><span class=\"location\">(.*)<\/span>/;
			my ($daterange, $duration, $location) = ($1, $2, $3);
			$rth->execute($j, $i, $daterange, $duration, $location, $experience->{'role'}, $experience->{'company'});
			$j++;
		}
	}
	my @education = @{$profile->{'education'}};
	if (scalar @education) {
		foreach my $education (@education) {
			$qth->execute($k, $i, $education->{'institute'}, $education->{'daterange'}, $education->{'degree'});
			$k++;
		}
	}
	if ($profile->{'skills'}) {
		my @skills = @{$profile->{'skills'}};
		foreach my $skill(@skills) {
			$uth->execute($m, $i, $skill);
			$m++;
		}
	}
	if ($profile->{'additionalInfo'}->{'interests'}) {
		my @interests = @{$profile->{'additionalInfo'}->{'interests'}};
		foreach my $interest(@interests) {
			$vth->execute($n, $i, $interest);
			$n++;
		}
	}
	$i++;
	if ($i%1000 == 0) {
		print "Updated 1000 records in profile table\n";
		print "Updated $j records in company table\n";
		print "Updated $k records in education table\n";
		print "Updated $m records in skill table\n";
		print "Updated $n records in interest table\n";
	}
}