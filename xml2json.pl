#!/usr/bin/perl
use strict;
use XML::Simple;
use Data::Dumper;
use JSON;
use XML::LibXSLT;
use XML::LibXML;
use  Getopt::Long;

my %param = (); 

GetOptions(
	'p=s' => \%param, 
);

my $xml = shift;
my $xsl = shift;

my $xslt = XML::LibXSLT->new();
my $style_src = XML::LibXML->load_xml(location=>$xsl, no_cdata=>1);

my $stylesheet = $xslt->parse_stylesheet($style_src);

my $results = $stylesheet->transform_file($xml,%param);
#print $results;
print $stylesheet->output_as_bytes($results);

