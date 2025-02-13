#import "Math";
#import "Basic";

@init_recs();

Health   :: @comp float32;

@init_components(Health);

EVENT_DAMAGE :: 2;

on_entity_death :: (entity: Entity, data: *void) -> bool {
    print("Entity % died!\n", entity.index);
    return true;
}

on_entity_damaged :: (entity: Entity, data: *void) -> bool {
    print("Entity % took damage!\n", entity.index);
    return true;
}

main :: () {
    init_ecs();

    subscribe(EVENT_DAMAGE, on_entity_damaged);

    entity := create_entity();
    entity_add(entity, .Health);

    emit(EVENT_DAMAGE, entity);
}