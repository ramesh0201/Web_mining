use URI;
use Web::Scraper;
use Data::Dumper;
use DBI;
use LWP::Simple;

@urls = ();
foreach $page("http://rakaposhi.eas.asu.edu/rao.html") {
	print "Checking $page\n";
	$html = get($page);
	@urls = $html =~ /\shref="?([^\s>"]+)/gi ;
}
$count = 0;
foreach $url(@urls) {
	print $url."\n";
	$count++;
	if($count == 10) {
		last;
	}
}

my $courses = scraper {
	process 'ol', "publications[]" => scraper {
		process 'li', "publication_year[]" => scraper {
			process 'a', href => '@href'
		}
	}
};
$count = 0;
foreach $url("http://rakaposhi.eas.asu.edu/papers-by-year.html") {
	my $res = $courses->scrape( URI->new($url) );
	open FIL, ">publication.txt";
	print FIL Dumper($res);
	close FIL;
	my $save = "C:\\Users\\HERO\\Desktop\\Publications\\Kambham";
	foreach $pub(@{$res->{publications}}) {
		foreach $pub_year(@{$pub->{publication_year}}) {
			print $pub_year->{href};
			my $file = get($pub_year->{href});
			$count++;

			open( FILE, '>', $save . 'filename'.$count.'.pdf' ) or die $!;
			binmode FILE;
			print FILE $file;
			close( FILE );
		}
	}
}