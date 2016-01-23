use URI;
use Web::Scraper;
use Data::Dumper;
use DBI;
use LWP::Simple;

my $courses = scraper {
	process 'div[class="entry-content"]', "publications[]" => scraper {
		process 'p', "publication_year[]" => scraper {
			process 'a', href => '@href'
		}
	}
};
$count = 0;
foreach $url("http://yoshikobayashi.com/?page_id=16") {
	my $res = $courses->scrape( URI->new($url) );
	open FIL, ">publication.txt";
	print FIL Dumper($res);
	close FIL;
	my $save = "C:\\Users\\HERO\\Desktop\\Publications\\Yoshiro";
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