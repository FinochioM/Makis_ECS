#import "String";
#import "Basic";

Table :: #import "Hash_Table";

#assert MAX_COMPONENTS < 64 "max components are 64 rn!";

#if MAX_COMPONENTS < 8 ComponentsEnum :: u8;
else #if MAX_COMPONENTS < 16 ComponentsEnum :: u16;
else #if MAX_COMPONENTS < 32 ComponentsEnum :: u32;
else ComponentsEnum :: u64;

INDEX_BITS                  :: 32;
GENERATION_BITS             :: 32;

MAX_INDEX                   :: (1 << INDEX_BITS) - 1;
MAX_GENERATION              :: (1 << GENERATION_BITS) - 1;

INVALID_ENTITY              :: Entity.{MAX_ENTITIES, 0};

Entity :: struct {
    index                   : u32;
    generation              : u32;

    is_valid                :: (self: Entity) -> bool {
        return self.index != MAX_INDEX && self.index < MAX_ENTITIES;
    }
}

Entity_Slot :: struct {
    generation              : u32;
    components              : Component;
}

entities_buffer             : [MAX_ENTITIES]Entity_Slot;
entities                    : []Entity_Slot;
free_indices                : [..]u32;
entity_count                : u32;

GroupInfo  :: struct {
    entities                : [..]Entity;
    mask                    : Component;
}

groups                      : Table.Table(Component, GroupInfo);

init_groups :: () {
    Table.init(*groups);
}

register_group :: (mask: Component) {
    info: GroupInfo;
    info.mask = mask;

    info.entities.count = 0;
    info.entities.data = null;
    info.entities.allocator = context.allocator;

    Table.table_add(*groups, mask, info);
}

update_group_membership :: (entity: Entity, old_components: Component, new_components: Component) {
    for * entry, i: groups.entries {
        if entry.hash < Table.FIRST_VALID_HASH continue;

        was_member := (old_components & entry.value.mask) == entry.value.mask;
        is_member := (new_components & entry.value.mask) == entry.value.mask;

        if !was_member && is_member {
            array_add(*entry.value.entities, entity);
        } else if was_member && !is_member {
            for entry.value.entities {
                if it == entity {
                    array_ordered_remove_by_index(*entry.value.entities, it_index);
                    break;
                }
            }
        }
    }
}

operator == :: inline (a: Entity, b: Entity) -> bool {
    return a.index == b.index && a.generation == b.generation;
}

operator != :: inline (a: Entity, b: Entity) -> bool {
    return !(a == b);
}

init_recs :: inline ($max_entities := 1000, $max_components := 30, $assert := true) -> string {
    b: String_Builder;
    init_string_builder(*b);
    defer reset(*b);

    append(*b, sprint("MAX_ENTITIES   :: %;\n", max_entities));
    append(*b, sprint("MAX_COMPONENTS :: %;\n", max_components));
    append(*b, sprint("RECS_ASSERT    :: %;\n", assert));

    append(*b, "#scope_file\n");
    append(*b, "#import \"Basic\";\n\n");
    append(*b, "init_ecs :: () {\n");
    append(*b, "    entities.count = MAX_ENTITIES;\n");
    append(*b, "    entities.data = entities_buffer.data;\n");
    append(*b, "    free_indices.count = 0;\n");     // Initialize count to 0
    append(*b, "    array_reserve(*free_indices, MAX_ENTITIES);\n");  // Reserve space for potential free indices
    append(*b, "    entity_count = 0;\n");
    append(*b, "    for * entities_buffer it.generation = 0;\n");
    append(*b, "    init_groups();\n");
    append(*b, "}\n\n");
    append(*b, "#scope_export\n");

    return builder_to_string(*b);
}

init_components :: inline ($types: ..Type) -> string {
    assert(is_constant(types));
    assert(types.count <= MAX_COMPONENTS);

    #insert #run -> string {
        b: String_Builder;
        init_string_builder(*b);
        defer reset(*b);

        append(*b, sprint("sizes : [%]u32 : .[\n", types.count));
        for types append(*b, sprint("\tsize_of(%),\n", it, it));
        append(*b, "];");

        return builder_to_string(*b);
    };

    b: String_Builder;
    init_string_builder(*b);
    defer reset(*b);

    append(*b, sprint("Component :: enum_flags % {\n", ComponentsEnum));
    for types append(*b, sprint("\t%;\n", it));
    append(*b, "}\n\n");

    for types {
        if sizes[it_index] > 0 append(*b, sprint("_% :: #run -> % { x: %; return x; };\n", it, it, it));
        else append(*b, sprint("_% :: %;\n", it, it));
    }

    append(*b, "\n");

    for types {
        if sizes[it_index] > 0 append(*b, sprint("entity_get :: inline (entity: Entity, $component: %) -> % {\n\t#if RECS_ASSERT assert(entity.index < MAX_ENTITIES);\n\t#if RECS_ASSERT assert(xx entities[entity.index].components & .%, \"entity doesnt have %\");\n\treturn %_Buff[entity.index];\n}\n", it, it, it, it, it));
        else append(*b, sprint("entity_get :: inline (entity: Entity, $component: %) -> % {\n\t#if RECS_ASSERT assert(entity.index < MAX_ENTITIES);\n\t#if RECS_ASSERT assert(xx entities[entity.index].components & .%, \"entity doesnt have %\");\n\tret: %;\n\treturn ret;\n}\n", it, it, it, it, it));
    }

    append(*b, "\n\n");

    for types {
        append(*b, sprint("type_get_component :: inline (_: %) -> Component { return .%; }\n", it, it));
        append(*b, sprint("type_update_buffer :: inline (e: Entity, x: %) {\n\t#if RECS_ASSERT assert(e.index < MAX_ENTITIES);\n\t%_Buff[e.index] = x;\n}\n\n", it, it, it));
    }

    for types if sizes[it_index] > 0 append(*b, sprint("%_Buff : [%]% = ---;\n", it, MAX_ENTITIES, it));

    return builder_to_string(*b);
}

create_entity :: inline () -> Entity {
    #if RECS_ASSERT assert(entity_count < MAX_ENTITIES);

    index: u32;
    if free_indices.count > 0 {
        index = pop(*free_indices);
    } else {
        index = entity_count;
        entity_count += 1;
    }

    entities[index].components = 0;

    return .{index, entities[index].generation};
}

create_entity :: inline(group: Component) -> Entity {
    entity := create_entity();
    entity_add(entity, group);

    return entity;
}

remove_entity :: inline (entity: Entity) {
    #if RECS_ASSERT assert(entity.is_valid(entity));
    #if RECS_ASSERT assert(entity.generation == entities[entity.index].generation);

    entities[entity.index].components = 0;

    entities[entity.index].generation += 1;
    if entities[entity.index].generation >= MAX_GENERATION {
        entities[entity.index].generation = 0;
    }

    array_add(*free_indices, entity.index);
}

entity_add :: inline (entity: Entity, component: $T) {
    #if RECS_ASSERT assert(entity.is_valid(entity));
    #if RECS_ASSERT assert(entity.generation == entities[entity.index].generation);
    #assert size_of(T) > 0;

    entities[entity.index].components |= type_get_component(component);
    type_update_buffer(entity, component);
}

entity_add :: inline (entity: Entity, component: Component) {
    #if RECS_ASSERT assert(entity.is_valid(entity));
    #if RECS_ASSERT assert(entity.generation == entities[entity.index].generation);

    old_components := entities[entity.index].components;
    entities[entity.index].components |= component;
    update_group_membership(entity, old_components, entities[entity.index].components);
}

entity_update :: inline (entity: Entity, component: $T) {
    #if RECS_ASSERT assert(entity.is_valid(entity));
    #if RECS_ASSERT assert(entity.generation == entities[entity.index].generation);
    #if RECS_ASSERT assert(!!(entities[entity.index].components & type_get_component(component)));

    type_update_buffer(entity, component);
}

entity_remove :: inline (entity: Entity, component: Component) {
    #if RECS_ASSERT assert(entity.is_valid(entity));
    #if RECS_ASSERT assert(entity.generation == entities[entity.index].generation);
    #if RECS_ASSERT assert(!!(entities[entity.index].components & component), "trying to remove component that entity doesn't have");

    old_components := entities[entity.index].components;
    entities[entity.index].components &= ~component;
    update_group_membership(entity, old_components, entities[entity.index].components);
}

entity_remove :: inline (entity: Entity, component: $T) {
    #if RECS_ASSERT assert(entity.index < MAX_ENTITIES);
    entities[entity.index].components &= ~type_get_component(component);
}

entity_have :: inline (entity: Entity, component: Component) -> bool {
    #if RECS_ASSERT assert(entity.is_valid(entity));
    #if RECS_ASSERT assert(entity.generation == entities[entity.index].generation);

    return !!(entities[entity.index].components & component);
}

entity_have :: inline (entity: Entity, component: $T) -> bool {
    #if RECS_ASSERT assert(entity.index < MAX_ENTITIES);
    return !!(entities[entity.index] & type_get_component(component));
}

entity_have_all :: inline (entity: Entity, components: ..Component) -> bool {
    #if RECS_ASSERT assert(entity.index < MAX_ENTITIES);
    comps : Component = 0;
    for components comps |= it;
    return (entities[entity.index].components & comps) == comps;
}

entity_have_any :: inline (entity: Entity, components: ..Component) -> bool {
    #if RECS_ASSERT assert(entity.index < MAX_ENTITIES);
    comps : Component = 0;
    for components comps |= it;
    return !!(entities[entity.index].components & comps);
}

entity_get :: inline (entity: Entity) -> Component {
    #if RECS_ASSERT assert(entity.is_valid(entity));
    #if RECS_ASSERT assert(entity.generation == entities[entity.index].generation);

    return entities[entity.index].components;
}

run_system :: inline (group: Component, $fn: (Entity)) {
    group_info := Table.table_find_pointer(*groups, group);
    if group_info {
        for group_info.entities fn(it);
    } else {
        for 0..entity_count - 1 {
            if entity_matches_group(.{xx it, entities[it].generation}, group) {
                e := Entity.{xx it, entities[it].generation};
                fn(e);
            }
        }
    }
}

run_system :: inline ($fn: (Entity)) {
    for 0..entity_count-1 {
        e := Entity.{xx it, entities[it].generation};
        fn(e);
    }
}

run_system_once :: inline (q: Component, $fn: (Entity)) {
    for entities if (it & q) == q {
        fn(xx it_index);
        break;
    }
}

run_system :: inline (e: Entity, $fn: (Entity)) { fn(e); }

run_system :: inline (e: []Entity, $fn: (Entity)) { for e fn(it); }

Entities :: struct { c: Component; };

iter_entities :: inline (components: ..Component) -> Entities {
    e: Entities = .{0};
    for components e.c |= it;
    return e;
}

for_expansion :: (iter: Entities, body: Code, flags: For_Flags) #expand {
    #assert flags == 0;

    index := 0;
    c := iter.c;

    for slot, i: entities {
        if (slot.components & c) == c {
            `it := Entity.{xx i, slot.generation};
            `it_index := index;

            #insert body;

            index += 1;
        }
    }
}

make_group :: inline($components: ..Type) -> Component {
    result: Component;

    #insert -> string {
        builder: String_Builder;
        init_string_builder(*builder);

        for components {
            print_to_builder(*builder, "result |= .%;\n", it);
        }

        return builder_to_string(*builder);
    }

    return result;
}

make_group :: inline(components: ..Component) -> Component {
    result: Component;
    for components result |= it;

    return result;
}

entity_matches_group :: inline(entity: Entity, group: Component) -> bool {
    return (entities[entity.index].components & group) == group;
}