package MooseX::DBIC::Meta::Role::Application::ToClass;
use Moose::Role;
use strict;
use warnings;

before apply_attributes => sub {
    my ( $self, $role, $class ) = @_;
    my $attr_metaclass = $class->attribute_metaclass;
    foreach my $attribute_name ( $role->get_attribute_list ) {
        my $attr = $role->get_attribute($attribute_name);
        # it if it has one already
        if (
            $class->has_attribute($attribute_name)
            &&

            # make sure we haven't seen this one already too
            $class->get_attribute($attribute_name) !=
            $role->get_attribute($attribute_name)
          )
        {
            next;
        }
        elsif ( grep { $_ =~ /^MooseX::DBIC::Meta::Role::Relationship/ } @{$attr->{traits} || []} ) {
            $self->apply_relationship( $role, $class, $attr );
        }
        elsif ( grep { $_ eq 'MooseX::DBIC::Meta::Role::Column' } @{$attr->{traits} || []} ) {
            $self->apply_column( $role, $class, $attr );
        }
    }
};

sub apply_column {
    my ( $self, $role, $class, $attr ) = @_;
    my $attr_metaclass = $class->attribute_metaclass->interpolate_class(
        { traits => $attr->{traits} }
    );
    $class->add_attribute( $attr->attribute_for_class($attr_metaclass) );
    $class->column_list( [ @{ $class->column_list }, $attr->name ] );
}

sub apply_relationship {
    my ( $self, $role, $class, $attr ) = @_;
    my $attr_metaclass = $class->attribute_metaclass->interpolate_class(
        { traits => $attr->{traits} }
    );
    my %options = %{$attr->original_options};
    $options{isa} = $options{isa}->($class) if(ref $options{isa} eq 'CODE');
    
    my $new = $class->add_attribute( $attr->name => \%options );
    $class->relationships([@{$class->relationships}, $new]);
    $class->relationship_list([@{$class->relationship_list}, $new->name]);
    $class->column_list([@{$class->column_list}, $new->name])
        if($new->does('MooseX::DBIC::Meta::Role::Column'));

}

1;
