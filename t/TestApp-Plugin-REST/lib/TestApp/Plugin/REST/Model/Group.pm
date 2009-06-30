use strict;
use warnings;

package TestApp::Plugin::REST::Model::Group;
use Jifty::DBI::Schema;

use TestApp::Plugin::REST::Record schema {
column 'name' =>
  type is 'text',
  is mandatory;

};

# Your model-specific methods go here.

1;

