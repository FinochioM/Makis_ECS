// V_0.1 - 12/02/2025.
// Test for the feature of "Entity Recycling".
/*
###############################################################################

This file demonstrates the Entity Recycling System, which handles efficient
reuse of entity slots when entities are created and destroyed.

The test shows three key aspects of entity recycling:

1. Index Reuse
   When an entity is removed, its index becomes available for reuse.
   New entities will prefer to use these recycled indices before creating new ones.

2. Generation Management
   Each entity slot maintains a generation counter that increments when the slot
   is recycled. This prevents accidental use of stale entity references.

3. Safety Checks
   The system automatically detects and prevents use of old entity references
   through generation checking.

Test Flow:
- Creates an entity (e1) and stores its index/generation
- Removes e1, making its slot available
- Creates new entity (e2) which reuses e1's index
- Verifies that e2 has same index but different generation
- Demonstrates that trying to use old e1 reference fails safely

Expected Output:

Creating first entity...
First entity - Index: 0, Generation: 0
Removing Entity...
Creating second entity...
Second entity - Index: 0, Generation: 1
Recycling verification:
SAME INDEX? true
DIFFERENT GENERATION? true
Trying to use old entity reference:
Correctly detected invalid entity!

###############################################################################
*/

#import "Math";
#import "Basic";

@init_recs();

Player   :: @comp void;
Position :: @comp Vector2;
Velocity :: @comp Vector2;
Health   :: @comp float32;

@init_components(Player, Position, Velocity, Health);

main :: () {
    init_ecs();

    print("Creating first entity...\n");
    e1 := create_entity();
    print("First entity - Index: %, Generation: %\n", e1.index, e1.generation);

    entity_add(e1, Position.{10, 20});

    old_index := e1.index;
    old_generation := e1.generation;

    print("Removing Entity...\n");
    remove_entity(e1);

    print("Creating second entity...\n");
    e2 := create_entity();
    print("Second entity - Index: %, Generation: %\n", e2.index, e2.generation);

    print("Recycling verification:\n");
    print("SAME INDEX? %\n", e2.index == old_index);
    print("DIFFERENT GENERATION? %\n", e2.generation != old_generation);

    print("\nTrying to use old entity reference:\n");

    if entity_have(e1, .Position) {
        print("ERROR: Should not reach this code!\n");
    } else {
        print("Correctly detected invalid entity!\n");
    }
}