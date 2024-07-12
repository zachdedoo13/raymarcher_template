pub mod state;

pub mod egui {
   pub mod gui;
   pub mod gui_example;
}

pub mod inbuilt {
   pub mod setup;
   pub mod vertex_library;
   pub mod vertex_package;
   pub mod event_loop;
}

pub mod packages {
   pub mod time_package;
   pub mod input_manager_package;
}

pub mod bundles {
   pub mod raymarching_bundle {
      pub mod raymarch_bundle;
      pub mod raymarching_pipeline;
      pub mod raymarching_package;
   }
}

pub mod utility {
   pub mod macros;
   pub mod functions;
   pub mod structs;
}
