// V_0.1 - 12/02/2025.
// Test for the feature of "Entity Recycling".


/*
###############################################################################

The expected result is:

"SAME INDEX?" = True.
"DIFFERENT GENERATION?" = True.

if entity_have -> throws an error (reaches the ASSERT).

##############################################################################
*/

#import "Math";
#import "Basic";

@init_recs();

// init comps
Player   :: @comp void;
Position :: @comp Vector2;
Velocity :: @comp Vector2;
Health   :: @comp float32;

@init_components(Player, Position, Velocity, Health);

// start da big
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