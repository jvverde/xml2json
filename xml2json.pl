#!/usr/bin/perl
use strict;
use XML::Simple;
use Data::Dumper;
use JSON;
use XML::LibXSLT;
use XML::LibXML;
use  Getopt::Long;

$\ ="\n";
my %param = ();
my $filter = '\.xml$'; 

GetOptions(
	'p=s' => \%param,
	'filter|f=s' => \$filter 
);

sub doit;
my $src = shift;
my $xsl = shift;

my $xslt = XML::LibXSLT->new();
my $style_src = XML::LibXML->load_xml(location=>$xsl, no_cdata=>1);

my $stylesheet = $xslt->parse_stylesheet($style_src);

if (-e $src and -f $src){
	doit $src;
}elsif(-d $src){
	my $re = qr/$filter/;
	opendir DIR, $src or die qq|Impossible to open $src|;
	my @files = grep {/$re/} grep {-f qq|$src/$_|} readdir DIR;
	closedir DIR;
	foreach (@files){
		my $in = qq|$src/$_|;
		my $out = $in;
		$out =~ s/$re/.json/;
		open STDOUT, qq|>$out|;
		doit $in;
	}	
}
sub doit{
	my $xml = shift;
	eval{
		my $results = $stylesheet->transform_file($xml,%param);
		#print $results;
		print $stylesheet->output_as_bytes($results);
	};
	warn $@ if $@;
}

