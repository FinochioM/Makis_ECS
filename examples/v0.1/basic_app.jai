#import "Math";

@init_recs();

Print    :: @comp void;
Position :: @comp Vector2;
Velocity :: @comp Vector2;

@init_components(Print, Position, Velocity);

printing_system :: inline (e: Entity) {
    pos := entity_get(e, _Position);
    print("%\n", pos);
}

movement_system :: inline (e: Entity) {
    pos := entity_get(e, _Position);
    vel := entity_get(e, _Velocity);
    pos.x += vel.x;
    pos.y += vel.y;
    entity_update(e, pos);
}

main :: () {
    e := create_entity();

    entity_add(e, Position.{});
    entity_add(e, Velocity.{1, 0});
    entity_add(e, .Print);

    e = create_entity();

    entity_add(e, Position.{});
    entity_add(e, Velocity.{0, 1});
    entity_add(e, .Print);

    e = create_entity();

    entity_add(e, Position.{});
    entity_add(e, .Print);

    for 0..3 {
        print("frame %:\n", it);
        run_system(.Position | .Velocity, movement_system);
        run_system(.Position | .Print, printing_system);
        print("\n");
    }

    for iter_entities(.Position) {
        entity_update(it, Position.{});
    }
}