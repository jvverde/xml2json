#!/usr/bin/perl
use strict;
use XML::Simple;
use Data::Dumper;
use JSON;
use XML::LibXSLT;
use XML::LibXML;


$\ ="\n---------------------\n";
my $xml = shift;
my $xsl = shift;

my $xslt = XML::LibXSLT->new();

my $source = XML::LibXML->load_xml(location => $xml);
my $style_doc = XML::LibXML->load_xml(location=>$xsl, no_cdata=>1);


my $stylesheet = $xslt->parse_stylesheet($style_doc);

my $results = $stylesheet->transform_file($xml);
#print $results;
print $stylesheet->output_as_bytes($results);
exit;


#binmode STDIN, ':encoding(UTF-8)';
undef $/;

#my $re = q/^(.+:)?Status$/;
my $re = shift;
my $file = <>;

#print $file;
my $ref = XMLin($file,SuppressEmpty => undef,ForceArray =>  qr/$re/);
my $r = JSON->new->ascii->pretty->encode($ref);
print $r;
