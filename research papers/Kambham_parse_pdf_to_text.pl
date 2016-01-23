#!/usr/bin/perl

  use strict;
  use warnings;

  use CAM::PDF;
  use CAM::PDF::PageText;

  #my $filename = shift || die "Supply pdf on command line\n";

  my $filename = "C:\\Users\\HERO\\Desktop\\Publications\\Kambhamfilename";
  my $pdf;
  foreach my $count(1..240) {
	my $filenamepdf = $filename. $count . ".pdf";
	print $filenamepdf;
	$pdf = CAM::PDF->new($filenamepdf);
	my $filenametxt = $filename. $count . ".txt";
	print $filenametxt;
	open(FIL, ">$filenametxt");
	print FIL text_from_page(1);
	close(FIL);
  }

  sub text_from_page {
          my $pg_num = shift;

          return
            CAM::PDF::PageText->render($pdf->getPageContentTree($pg_num));
  }