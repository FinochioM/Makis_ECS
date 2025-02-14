// V_0.1 - 13/02/2025
// Example demonstrating basic entity hierarchy functionality.
/*
###############################################################################

This example demonstrates the basic usage of hierarchical relationships between
entities using the ECS library. It shows how to:
- Create parent-child relationships between entities
- Add and retrieve entity names
- Query children of a parent entity
- Clean up hierarchies by destroying parent entities with their children

This serves as a good starting point for understanding how to structure
hierarchical entity relationships in your projects.

Expected result:

Child: child1
Child: Child 2

###############################################################################
*/

#import "Math";
#import "Basic";

@init_recs();

Health :: @comp struct {
    value: float32;
    max_value: float32;
};

Name :: @comp struct {
    value: string;
};

@init_components(Health, Name, ParentComponent);

main :: () {
    init_ecs();

    root := create_entity();
    entity_add(root, Name.{"root"});

    child1 := create_entity();
    entity_add(child1, Name.{"child1"});
    set_parent(child1, root);

    child2 := create_entity();
    entity_add(child2, Name.{"Child 2"});
    set_parent(child2, root);

    children := get_children(root);
    for children print("Child: %\n", entity_get(it, _Name).value);
    array_free(children);

    destroy_with_children(root);
}