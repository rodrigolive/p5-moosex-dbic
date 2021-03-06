use MooseX::Attribute::Deflator::Moose;

package MyRole;
use Moose::Role;
use MooseX::DBIC;

has_column 'role';
belongs_to hasmany => ( isa => 'HasMany' );

package SecondRole;
use Moose::Role;
use MooseX::DBIC;

has_column 'second';

package HasMany;
use Moose;
use MooseX::DBIC;
with 'MyRole';

has_many classes => ( isa => 'MyClass', foreign_key => 'hasmany' );

__PACKAGE__->meta->make_immutable;

package MyClass;
use Moose;
use Moose;
use MooseX::DBIC;
with qw(MyRole SecondRole);

has_column foo => ( is => 'rw' );
has_column bar => ( is => 'rw', required => 1 );

__PACKAGE__->meta->make_immutable;

package main;
use Test::More;

ok( MyClass->meta->meta->does_role('MooseX::DBIC::Meta::Role::Class' ) );
ok( MyClass->meta->get_column('id')->does('MooseX::DBIC::Meta::Role::Column') );
ok( MyClass->meta->get_column('role')->does('MooseX::DBIC::Meta::Role::Column')
);
ok( MyClass->meta->get_column('hasmany') );
ok( MyClass->meta->get_column('hasmany')->foreign_key );
ok( MyClass->meta->get_relationship('hasmany') );

ok( HasMany->meta->has_column('id'), 'HasMany has column id' );
ok( HasMany->meta->get_relationship('classes')->foreign_key );

ok( MyClass->meta->get_column('id')->primary_key );
TODO: {
    local $TODO = 'role composition';
    ok(MyClass->meta->get_attribute('second'), 'attribute exists');
    ok(MyClass->meta->get_column('second'), 'composite role works');
}
my $foo = MyClass->new( -result_source => 1 );
ok( $foo->id );
done_testing;
