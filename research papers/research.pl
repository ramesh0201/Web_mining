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
	print $url;
	$count++;
	if($count == 10) {
		last;
	}
}