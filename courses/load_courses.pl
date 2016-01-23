use URI;
use Web::Scraper;
use Data::Dumper;
use DBI;

# First, create your scraper block
my $courses = scraper {
	# Parse all TDs inside 'table[width="100%]"', store them into
	# an array 'courses'.  We embed other scrapers for each TD.
	process 'table[id="CatalogList"]', "courses[]" => scraper {
		# And, in each TD,
		# get the course title of "a" element
		process 'td[class="titleColumnValue"]', "coursetitle[]" => scraper {
			process 'a', name => 'TEXT';
		},
		process 'td[class="classNbrColumnValue"]', "classnumber[]" => scraper {
			process 'a', name => 'TEXT';
		},
		process 'td[class="subjectNumberColumnValue"]', "subjectnumber[]" => 'TEXT',
		process 'td[class="hoursColumnValue"]', "credits[]" => 'TEXT',
		process 'td[class="startDateColumnValue"]', "schedule[]" => scraper {
			process 'span a', name => 'TEXT';
		},
		process 'td[class="dayListColumnValue"]', "daylist[]" => 'TEXT',
		process 'td[class="startTimeDateColumnValue"]', "starttime[]" => 'TEXT',
		process 'td[class="endTimeDateColumnValue"]', "endtime[]" => 'TEXT',
		process 'td[class="locationBuildingColumnValue"]', "location[]" => scraper {
			process 'a', name => 'TEXT';
		},
		process 'td[class="instructorListColumnValue"]', "instructor[]" => scraper {
			process 'span span span span a span', name => 'TEXT';
		},
		process 'td[class="availableSeatsColumnValue"]', "seats[]" => scraper {
			process 'td[style="text-align:right;padding:0px;width:22px; border:none"]', available => 'TEXT',
			process 'td[style="text-align:left;padding:0px;width:22px;border:none"]', total => 'TEXT',
		},
	}
};
my $dbh = DBI->connect('dbi:mysql:test','root','root') or die "Connection Error: $DBI::errstr\n";
#$sql = "select * from samples";
#$sth = $dbh->prepare($sql);
#$sth->execute or die "SQL Error: $DBI::errstr\n";
#while (@row = $sth->fetchrow_array)
#{ print "@row\n"; }
foreach $url ("file:///C:/Users/HERO/Desktop/Class%20Search%20_%20Course%20Catalog.html", "file:///C:/Users/HERO/Desktop/Class%20Search%20_%20Course%20Catalog_sum.html", "file:///C:/Users/HERO/Desktop/Class%20Search%20_%20Course%20Catalog_spr.html") {
	my $res = $courses->scrape( URI->new($url) );
	#my $res = $courses->scrape( URI->new("https://webapp4.asu.edu/catalog/classlist?c=TEMPE&s=CSE&t=2157&e=open&hon=F"));
	open (FIL,'>data.txt');
	#print FIL Dumper($res);
	close (FIL);
	$hashreference = @{$res->{courses}}[0];
	# iterate the array 'courses'
	my $i = 0;
	my @results;
	my $last = 0;
	while (1) {
		for my $detail (keys %{$hashreference}) {
			#print "The value is: ".$hashreference->{$detail}[$i]."\n";
			if (not defined $hashreference->{$detail}[$i]) {
				$last = 1;
			}
			if (ref($hashreference->{$detail}[$i]) eq 'HASH') {
				if ($detail eq 'seats') {
					#print "seats available is: ".$hashreference->{$detail}[$i]->{available}."\n";
					#print "seats total is: ".$hashreference->{$detail}[$i]->{total}."\n";
					$results[$i]->{'seatsavailable'} = $hashreference->{$detail}[$i]->{'available'};
					$results[$i]->{'seatstotal'} = $hashreference->{$detail}[$i]->{'total'};
				}
				else {
					#print "$detail is: ".$hashreference->{$detail}[$i]->{name}."\n";
					$results[$i]->{$detail} = $hashreference->{$detail}[$i]->{name};
				}
			}
			else {
				$hashreference->{$detail}[$i] =~ s/\x{a0}//g;
				#print "$detail is $hashreference->{$detail}[i]\n";
				$results[$i]->{$detail} = $hashreference->{$detail}[$i];
			}
		}
		if ($last == 1) {
			#print $i;
			last;
		}
		$i++;
	}
	foreach my $result(@results) {
		#print $result->{'classnumber'};
		my $insert_query = "INSERT INTO test.courses(classnumber,subjectnumber,coursetitle,credits,instructor,location,schedule,starttime,endtime,daylist,seatsavailable,seatstotal) values(?,?,?,?,?,?,?,?,?,?,?,?)";
		my $sth= $dbh->prepare( $insert_query );
		$sth->execute($result->{'classnumber'}, $result->{'subjectnumber'}, $result->{'coursetitle'}, $result->{'credits'}, $result->{'instructor'}, $result->{'location'}, $result->{'schedule'}, $result->{'starttime'}, $result->{'endtime'}, $result->{'daylist'}, $result->{'seatsavailable'}, $result->{'seatstotal'});
	}
	@results =();
}