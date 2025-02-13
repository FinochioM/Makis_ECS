#run {
    set_build_options_dc(.{do_output = false});

    w := compiler_create_workspace("Target workspace");
    options := get_build_options(w);

    args := options.compile_time_command_line;
    release := array_find(args, "release");

    options.output_executable_name = "mecs";

    if release set_optimization(*options, .VERY_OPTIMIZED, false);
    set_build_options(options, w);

    compiler_begin_intercept(w);
    if release add_build_string(tprint("DEBUG :: false;\n"), w);
    else add_build_string(tprint("DEBUG :: true;\n"), w);

    main, ok := read_entire_file("src/main.jai");
    assert(ok, "main.jai not found!");

    main = replace(main, "@init_recs(", "#insert #run init_recs(");
    main = replace(main, "@init_components(", "#insert #run init_components(");
    main = replace(main, "@component()", "#type,distinct void");
    main = replace(main, "@comp()", "#type,distinct void");
    main = replace(main, "@component", "#type,distinct");
    main = replace(main, "@comp", "#type,distinct");
    main = replace(main, "@group", "#run make_group");

    add_build_string(main, w);
    add_build_file("src/mecs.jai", w);
    compiler_end_intercept(w);
}

#import "Compiler";
#import "Basic";
#import "File";
#import "String";