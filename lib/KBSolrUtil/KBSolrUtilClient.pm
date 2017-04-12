package KBSolrUtil::KBSolrUtilClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
use Time::HiRes;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

KBSolrUtil::KBSolrUtilClient

=head1 DESCRIPTION


A KBase module: KBSolrUtil
This module contains the utility methods and configuration details to access the KBase SOLR cores.


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => KBSolrUtil::KBSolrUtilClient::RpcClient->new,
	url => $url,
	headers => [],
    };
    my %arg_hash = @args;
    $self->{async_job_check_time} = 0.1;
    if (exists $arg_hash{"async_job_check_time_ms"}) {
        $self->{async_job_check_time} = $arg_hash{"async_job_check_time_ms"} / 1000.0;
    }
    $self->{async_job_check_time_scale_percent} = 150;
    if (exists $arg_hash{"async_job_check_time_scale_percent"}) {
        $self->{async_job_check_time_scale_percent} = $arg_hash{"async_job_check_time_scale_percent"};
    }
    $self->{async_job_check_max_time} = 300;  # 5 minutes
    if (exists $arg_hash{"async_job_check_max_time_ms"}) {
        $self->{async_job_check_max_time} = $arg_hash{"async_job_check_max_time_ms"} / 1000.0;
    }
    my $service_version = 'release';
    if (exists $arg_hash{"service_version"}) {
        $service_version = $arg_hash{"service_version"};
    }
    $self->{service_version} = $service_version;

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my %arg_hash2 = @args;
	if (exists $arg_hash2{"token"}) {
	    $self->{token} = $arg_hash2{"token"};
	} elsif (exists $arg_hash2{"user_id"}) {
	    my $token = Bio::KBase::AuthToken->new(@args);
	    if (!$token->error_message) {
	        $self->{token} = $token->token;
	    }
	}
	
	if (exists $self->{token})
	{
	    $self->{client}->{token} = $self->{token};
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}

sub _check_job {
    my($self, @args) = @_;
# Authentication: ${method.authentication}
    if ((my $n = @args) != 1) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function _check_job (received $n, expecting 1)");
    }
    {
        my($job_id) = @args;
        my @_bad_arguments;
        (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument 0 \"job_id\" (it should be a string)");
        if (@_bad_arguments) {
            my $msg = "Invalid arguments passed to _check_job:\n" . join("", map { "\t$_\n" } @_bad_arguments);
            Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                   method_name => '_check_job');
        }
    }
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "KBSolrUtil._check_job",
        params => \@args});
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => '_check_job',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
                          );
        } else {
            return $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method _check_job",
                        status_line => $self->{client}->status_line,
                        method_name => '_check_job');
    }
}




=head2 index_in_solr

  $output = $obj->index_in_solr($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a KBSolrUtil.IndexInSolrParams
$output is an int
IndexInSolrParams is a reference to a hash where the following keys are defined:
	solr_core has a value which is a string
	doc_data has a value which is a reference to a list where each element is a KBSolrUtil.docdata
docdata is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$params is a KBSolrUtil.IndexInSolrParams
$output is an int
IndexInSolrParams is a reference to a hash where the following keys are defined:
	solr_core has a value which is a string
	doc_data has a value which is a reference to a list where each element is a KBSolrUtil.docdata
docdata is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

The index_in_solr function that returns 1 if succeeded otherwise 0

=back

=cut

sub index_in_solr
{
    my($self, @args) = @_;
    my $job_id = $self->_index_in_solr_submit(@args);
    my $async_job_check_time = $self->{async_job_check_time};
    while (1) {
        Time::HiRes::sleep($async_job_check_time);
        $async_job_check_time *= $self->{async_job_check_time_scale_percent} / 100.0;
        if ($async_job_check_time > $self->{async_job_check_max_time}) {
            $async_job_check_time = $self->{async_job_check_max_time};
        }
        my $job_state_ref = $self->_check_job($job_id);
        if ($job_state_ref->{"finished"} != 0) {
            if (!exists $job_state_ref->{"result"}) {
                $job_state_ref->{"result"} = [];
            }
            return wantarray ? @{$job_state_ref->{"result"}} : $job_state_ref->{"result"}->[0];
        }
    }
}

sub _index_in_solr_submit {
    my($self, @args) = @_;
# Authentication: required
    if ((my $n = @args) != 1) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function _index_in_solr_submit (received $n, expecting 1)");
    }
    {
        my($params) = @args;
        my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
            my $msg = "Invalid arguments passed to _index_in_solr_submit:\n" . join("", map { "\t$_\n" } @_bad_arguments);
            Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                   method_name => '_index_in_solr_submit');
        }
    }
    my $context = undef;
    if ($self->{service_version}) {
        $context = {'service_ver' => $self->{service_version}};
    }
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "KBSolrUtil._index_in_solr_submit",
        params => \@args, context => $context});
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => '_index_in_solr_submit',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
            );
        } else {
            return $result->result->[0];  # job_id
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method _index_in_solr_submit",
                        status_line => $self->{client}->status_line,
                        method_name => '_index_in_solr_submit');
    }
}

 


=head2 exists_in_solr

  $output = $obj->exists_in_solr($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a KBSolrUtil.ExistsInputParams
$output is an int
ExistsInputParams is a reference to a hash where the following keys are defined:
	search_core has a value which is a string
	search_query has a value which is a KBSolrUtil.searchdata
searchdata is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$params is a KBSolrUtil.ExistsInputParams
$output is an int
ExistsInputParams is a reference to a hash where the following keys are defined:
	search_core has a value which is a string
	search_query has a value which is a KBSolrUtil.searchdata
searchdata is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

The exists_in_solr function that returns 0 or 1

=back

=cut

sub exists_in_solr
{
    my($self, @args) = @_;
    my $job_id = $self->_exists_in_solr_submit(@args);
    my $async_job_check_time = $self->{async_job_check_time};
    while (1) {
        Time::HiRes::sleep($async_job_check_time);
        $async_job_check_time *= $self->{async_job_check_time_scale_percent} / 100.0;
        if ($async_job_check_time > $self->{async_job_check_max_time}) {
            $async_job_check_time = $self->{async_job_check_max_time};
        }
        my $job_state_ref = $self->_check_job($job_id);
        if ($job_state_ref->{"finished"} != 0) {
            if (!exists $job_state_ref->{"result"}) {
                $job_state_ref->{"result"} = [];
            }
            return wantarray ? @{$job_state_ref->{"result"}} : $job_state_ref->{"result"}->[0];
        }
    }
}

sub _exists_in_solr_submit {
    my($self, @args) = @_;
# Authentication: required
    if ((my $n = @args) != 1) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function _exists_in_solr_submit (received $n, expecting 1)");
    }
    {
        my($params) = @args;
        my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
            my $msg = "Invalid arguments passed to _exists_in_solr_submit:\n" . join("", map { "\t$_\n" } @_bad_arguments);
            Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                   method_name => '_exists_in_solr_submit');
        }
    }
    my $context = undef;
    if ($self->{service_version}) {
        $context = {'service_ver' => $self->{service_version}};
    }
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "KBSolrUtil._exists_in_solr_submit",
        params => \@args, context => $context});
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => '_exists_in_solr_submit',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
            );
        } else {
            return $result->result->[0];  # job_id
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method _exists_in_solr_submit",
                        status_line => $self->{client}->status_line,
                        method_name => '_exists_in_solr_submit');
    }
}

 


=head2 get_total_count

  $output = $obj->get_total_count($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a KBSolrUtil.TotalCountParams
$output is an int
TotalCountParams is a reference to a hash where the following keys are defined:
	search_core has a value which is a string
	search_query has a value which is a KBSolrUtil.searchdata
searchdata is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$params is a KBSolrUtil.TotalCountParams
$output is an int
TotalCountParams is a reference to a hash where the following keys are defined:
	search_core has a value which is a string
	search_query has a value which is a KBSolrUtil.searchdata
searchdata is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

The get_total_count function that returns a positive integer (including 0) or -1

=back

=cut

sub get_total_count
{
    my($self, @args) = @_;
    my $job_id = $self->_get_total_count_submit(@args);
    my $async_job_check_time = $self->{async_job_check_time};
    while (1) {
        Time::HiRes::sleep($async_job_check_time);
        $async_job_check_time *= $self->{async_job_check_time_scale_percent} / 100.0;
        if ($async_job_check_time > $self->{async_job_check_max_time}) {
            $async_job_check_time = $self->{async_job_check_max_time};
        }
        my $job_state_ref = $self->_check_job($job_id);
        if ($job_state_ref->{"finished"} != 0) {
            if (!exists $job_state_ref->{"result"}) {
                $job_state_ref->{"result"} = [];
            }
            return wantarray ? @{$job_state_ref->{"result"}} : $job_state_ref->{"result"}->[0];
        }
    }
}

sub _get_total_count_submit {
    my($self, @args) = @_;
# Authentication: required
    if ((my $n = @args) != 1) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function _get_total_count_submit (received $n, expecting 1)");
    }
    {
        my($params) = @args;
        my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
            my $msg = "Invalid arguments passed to _get_total_count_submit:\n" . join("", map { "\t$_\n" } @_bad_arguments);
            Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                   method_name => '_get_total_count_submit');
        }
    }
    my $context = undef;
    if ($self->{service_version}) {
        $context = {'service_ver' => $self->{service_version}};
    }
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "KBSolrUtil._get_total_count_submit",
        params => \@args, context => $context});
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => '_get_total_count_submit',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
            );
        } else {
            return $result->result->[0];  # job_id
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method _get_total_count_submit",
                        status_line => $self->{client}->status_line,
                        method_name => '_get_total_count_submit');
    }
}

 


=head2 search_solr

  $output = $obj->search_solr($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a KBSolrUtil.SearchSolrParams
$output is a KBSolrUtil.solrresponse
SearchSolrParams is a reference to a hash where the following keys are defined:
	search_core has a value which is a string
	search_param has a value which is a KBSolrUtil.searchdata
	search_query has a value which is a KBSolrUtil.searchdata
	result_format has a value which is a string
	group_option has a value which is a string
searchdata is a reference to a hash where the key is a string and the value is a string
solrresponse is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$params is a KBSolrUtil.SearchSolrParams
$output is a KBSolrUtil.solrresponse
SearchSolrParams is a reference to a hash where the following keys are defined:
	search_core has a value which is a string
	search_param has a value which is a KBSolrUtil.searchdata
	search_query has a value which is a KBSolrUtil.searchdata
	result_format has a value which is a string
	group_option has a value which is a string
searchdata is a reference to a hash where the key is a string and the value is a string
solrresponse is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

The search_solr function that returns a solrresponse consisting of a string in the format of the specified 'result_format' in SearchSolrParams

=back

=cut

sub search_solr
{
    my($self, @args) = @_;
    my $job_id = $self->_search_solr_submit(@args);
    my $async_job_check_time = $self->{async_job_check_time};
    while (1) {
        Time::HiRes::sleep($async_job_check_time);
        $async_job_check_time *= $self->{async_job_check_time_scale_percent} / 100.0;
        if ($async_job_check_time > $self->{async_job_check_max_time}) {
            $async_job_check_time = $self->{async_job_check_max_time};
        }
        my $job_state_ref = $self->_check_job($job_id);
        if ($job_state_ref->{"finished"} != 0) {
            if (!exists $job_state_ref->{"result"}) {
                $job_state_ref->{"result"} = [];
            }
            return wantarray ? @{$job_state_ref->{"result"}} : $job_state_ref->{"result"}->[0];
        }
    }
}

sub _search_solr_submit {
    my($self, @args) = @_;
# Authentication: required
    if ((my $n = @args) != 1) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function _search_solr_submit (received $n, expecting 1)");
    }
    {
        my($params) = @args;
        my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
            my $msg = "Invalid arguments passed to _search_solr_submit:\n" . join("", map { "\t$_\n" } @_bad_arguments);
            Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                   method_name => '_search_solr_submit');
        }
    }
    my $context = undef;
    if ($self->{service_version}) {
        $context = {'service_ver' => $self->{service_version}};
    }
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "KBSolrUtil._search_solr_submit",
        params => \@args, context => $context});
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => '_search_solr_submit',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
            );
        } else {
            return $result->result->[0];  # job_id
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method _search_solr_submit",
                        status_line => $self->{client}->status_line,
                        method_name => '_search_solr_submit');
    }
}

 


=head2 add_json_2solr

  $output = $obj->add_json_2solr($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a KBSolrUtil.IndexJsonParams
$output is an int
IndexJsonParams is a reference to a hash where the following keys are defined:
	solr_core has a value which is a string
	json_data has a value which is a string

</pre>

=end html

=begin text

$params is a KBSolrUtil.IndexJsonParams
$output is an int
IndexJsonParams is a reference to a hash where the following keys are defined:
	solr_core has a value which is a string
	json_data has a value which is a string


=end text

=item Description

The add_json_2solr function that returns 1 if succeeded otherwise 0

=back

=cut

sub add_json_2solr
{
    my($self, @args) = @_;
    my $job_id = $self->_add_json_2solr_submit(@args);
    my $async_job_check_time = $self->{async_job_check_time};
    while (1) {
        Time::HiRes::sleep($async_job_check_time);
        $async_job_check_time *= $self->{async_job_check_time_scale_percent} / 100.0;
        if ($async_job_check_time > $self->{async_job_check_max_time}) {
            $async_job_check_time = $self->{async_job_check_max_time};
        }
        my $job_state_ref = $self->_check_job($job_id);
        if ($job_state_ref->{"finished"} != 0) {
            if (!exists $job_state_ref->{"result"}) {
                $job_state_ref->{"result"} = [];
            }
            return wantarray ? @{$job_state_ref->{"result"}} : $job_state_ref->{"result"}->[0];
        }
    }
}

sub _add_json_2solr_submit {
    my($self, @args) = @_;
# Authentication: required
    if ((my $n = @args) != 1) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function _add_json_2solr_submit (received $n, expecting 1)");
    }
    {
        my($params) = @args;
        my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
            my $msg = "Invalid arguments passed to _add_json_2solr_submit:\n" . join("", map { "\t$_\n" } @_bad_arguments);
            Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                   method_name => '_add_json_2solr_submit');
        }
    }
    my $context = undef;
    if ($self->{service_version}) {
        $context = {'service_ver' => $self->{service_version}};
    }
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "KBSolrUtil._add_json_2solr_submit",
        params => \@args, context => $context});
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => '_add_json_2solr_submit',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
            );
        } else {
            return $result->result->[0];  # job_id
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method _add_json_2solr_submit",
                        status_line => $self->{client}->status_line,
                        method_name => '_add_json_2solr_submit');
    }
}

 
 
sub status
{
    my($self, @args) = @_;
    my $job_id = undef;
    if ((my $n = @args) != 0) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function status (received $n, expecting 0)");
    }
    my $context = undef;
    if ($self->{service_version}) {
        $context = {'service_ver' => $self->{service_version}};
    }
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "KBSolrUtil._status_submit",
        params => \@args, context => $context});
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => '_status_submit',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
            );
        } else {
            $job_id = $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method _status_submit",
                        status_line => $self->{client}->status_line,
                        method_name => '_status_submit');
    }
    my $async_job_check_time = $self->{async_job_check_time};
    while (1) {
        Time::HiRes::sleep($async_job_check_time);
        $async_job_check_time *= $self->{async_job_check_time_scale_percent} / 100.0;
        if ($async_job_check_time > $self->{async_job_check_max_time}) {
            $async_job_check_time = $self->{async_job_check_max_time};
        }
        my $job_state_ref = $self->_check_job($job_id);
        if ($job_state_ref->{"finished"} != 0) {
            if (!exists $job_state_ref->{"result"}) {
                $job_state_ref->{"result"} = [];
            }
            return wantarray ? @{$job_state_ref->{"result"}} : $job_state_ref->{"result"}->[0];
        }
    }
}
   

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "KBSolrUtil.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'add_json_2solr',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method add_json_2solr",
            status_line => $self->{client}->status_line,
            method_name => 'add_json_2solr',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for KBSolrUtil::KBSolrUtilClient\n";
    }
    if ($sMajor == 0) {
        warn "KBSolrUtil::KBSolrUtilClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 bool

=over 4



=item Description

a bool defined as int


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 searchdata

=over 4



=item Description

User provided parameter data.
Arbitrary key-value pairs provided by the user.


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a string

=end text

=back



=head2 docdata

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a string

=end text

=back



=head2 solrresponse

=over 4



=item Description

Solr response data for search requests.
Arbitrary key-value pairs returned by the solr.


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a string

=end text

=back



=head2 IndexInSolrParams

=over 4



=item Description

Arguments for the index_in_solr function - send doc data to solr for indexing

string solr_core - the name of the solr core to index to
list<docdata> doc_data - the doc to be indexed, a list of hashes


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
solr_core has a value which is a string
doc_data has a value which is a reference to a list where each element is a KBSolrUtil.docdata

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
solr_core has a value which is a string
doc_data has a value which is a reference to a list where each element is a KBSolrUtil.docdata


=end text

=back



=head2 ExistsInputParams

=over 4



=item Description

Arguments for the exists_in_solr function - search solr according to the parameters passed and return 1 if found at least one doc 0 if nothing found. A shorter version of search_solr.

string search_core - the name of the solr core to be searched
searchdata search_query - arbitrary user-supplied key-value pairs specifying the fields to be searched and their values to be matched, a hash which specifies how the documents will be searched, see the example below:
        search_query={
                parent_taxon_ref => '1779/116411/1',
                rank => 'species',
                scientific_lineage => 'cellular organisms; Bacteria; Proteobacteria; Alphaproteobacteria; Rhizobiales; Bradyrhizobiaceae; Bradyrhizobium',
                scientific_name => 'Bradyrhizobium sp.*',
                domain => 'Bacteria'
        }
OR, simply:
        search_query= { q => "*" };


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
search_core has a value which is a string
search_query has a value which is a KBSolrUtil.searchdata

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
search_core has a value which is a string
search_query has a value which is a KBSolrUtil.searchdata


=end text

=back



=head2 TotalCountParams

=over 4



=item Description

Arguments for the get_total_count function - search solr according to the parameters passed and return the count of docs found, or -1 if error.

string search_core - the name of the solr core to be searched
searchdata search_query - arbitrary user-supplied key-value pairs specifying the fields to be searched and their values to be matched, a hash which specifies how the documents will be searched, see the example below:
        search_query={
                parent_taxon_ref => '1779/116411/1',
                rank => 'species',
                scientific_lineage => 'cellular organisms; Bacteria; Proteobacteria; Alphaproteobacteria; Rhizobiales; Bradyrhizobiaceae; Bradyrhizobium',
                scientific_name => 'Bradyrhizobium sp.*',
                domain => 'Bacteria'
        }
OR, simply:
        search_query= { q => "*" };


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
search_core has a value which is a string
search_query has a value which is a KBSolrUtil.searchdata

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
search_core has a value which is a string
search_query has a value which is a KBSolrUtil.searchdata


=end text

=back



=head2 SearchSolrParams

=over 4



=item Description

Arguments for the search_solr function - search solr according to the parameters passed and return a string

string search_core - the name of the solr core to be searched
searchdata search_param - arbitrary user-supplied key-value pairs for controlling the presentation of the query response, 
                        a hash, see the example below:
        search_param={
                fl => 'object_id,gene_name,genome_source',
                wt => 'json',
                rows => 20,
                sort => 'object_id asc',
                hl => 'false',
                start => 100
        }
OR, default to SOLR default settings, i
        search_param={{fl=>'*',wt=>'xml',rows=>10,sort=>'',hl=>'false',start=>0}

searchdata search_query - arbitrary user-supplied key-value pairs specifying the fields to be searched and their values 
                        to be matched, a hash which specifies how the documents will be searched, see the example below:
        search_query={
                parent_taxon_ref => '1779/116411/1',
                rank => 'species',
                scientific_lineage => 'cellular organisms; Bacteria; Proteobacteria; Alphaproteobacteria; Rhizobiales; Bradyrhizobiaceae; Bradyrhizobium',
                scientific_name => 'Bradyrhizobium sp.*',
                domain => 'Bacteria'
        }
OR, simply:
        search_query= { q => "*" };

string result_format - the format of the search result, 'xml' as the default, can be 'json', 'csv', etc.
string group_option - the name of the field to be grouped for the result


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
search_core has a value which is a string
search_param has a value which is a KBSolrUtil.searchdata
search_query has a value which is a KBSolrUtil.searchdata
result_format has a value which is a string
group_option has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
search_core has a value which is a string
search_param has a value which is a KBSolrUtil.searchdata
search_query has a value which is a KBSolrUtil.searchdata
result_format has a value which is a string
group_option has a value which is a string


=end text

=back



=head2 IndexJsonParams

=over 4



=item Description

Arguments for the add_json_2solr function - send a JSON doc data to solr for indexing

string solr_core - the name of the solr core to index to
string json_data - the doc to be indexed, a JSON string 
=for example:
     $json_data = '[
     {
"taxonomy_id":1297193,
"domain":"Eukaryota",
"genetic_code":1,
"embl_code":"CS",
"division_id":1,
"inherited_div_flag":1,
"inherited_MGC_flag":1,
"parent_taxon_ref":"12570/1217907/1",
"scientific_name":"Camponotus sp. MAS010",
"mitochondrial_genetic_code":5,
"hidden_subtree_flag":0,
"scientific_lineage":"cellular organisms; Eukaryota; Opisthokonta; Metazoa; Eumetazoa; Bilateria; Protostomia; Ecdysozoa; Panarthropoda; Arthropoda; Mandibulata; Pancrustacea; Hexapoda; Insecta; Dicondylia; Pterygota; Neoptera; Endopterygota; Hymenoptera; Apocrita; Aculeata; Vespoidea; Formicidae; Formicinae; Camponotini; Camponotus",
"rank":"species",
"ws_ref":"12570/1253105/1",
"kingdom":"Metazoa",
"GenBank_hidden_flag":1,
"inherited_GC_flag":1,"
"deleted":0
      },
      {
"inherited_MGC_flag":1,
"inherited_div_flag":1,
"parent_taxon_ref":"12570/1217907/1",
"genetic_code":1,
"division_id":1,
"embl_code":"CS",
"domain":"Eukaryota",
"taxonomy_id":1297190,
"kingdom":"Metazoa",
"GenBank_hidden_flag":1,
"inherited_GC_flag":1,
"ws_ref":"12570/1253106/1",
"scientific_lineage":"cellular organisms; Eukaryota; Opisthokonta; Metazoa; Eumetazoa; Bilateria; Protostomia; Ecdysozoa; Panarthropoda; Arthropoda; Mandibulata; Pancrustacea; Hexapoda; Insecta; Dicondylia; Pterygota; Neoptera; Endopterygota; Hymenoptera; Apocrita; Aculeata; Vespoidea; Formicidae; Formicinae; Camponotini; Camponotus",
"rank":"species",
"scientific_name":"Camponotus sp. MAS003",
"hidden_subtree_flag":0,
"mitochondrial_genetic_code":5,
"deleted":0
      },
...
  ]';
=cut end of example


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
solr_core has a value which is a string
json_data has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
solr_core has a value which is a string
json_data has a value which is a string


=end text

=back



=cut

package KBSolrUtil::KBSolrUtilClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
