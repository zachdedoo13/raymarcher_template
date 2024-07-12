use std::borrow::Cow;
use std::fs;
use std::path::Path;
use std::process::Command;
use wgpu::{Color, CommandEncoder, IndexFormat, RenderPipeline, ShaderModule, ShaderModuleDescriptor, ShaderSource, TextureView};
use crate::bundles::raymarching_bundle::raymarching_package::RaymarchingPackage;
use crate::inbuilt::setup::Setup;
use crate::inbuilt::vertex_library::{SQUARE_INDICES, SQUARE_VERTICES};
use crate::inbuilt::vertex_package::{Vertex, VertexPackage};

pub struct RaymarchingPipeline {
   vertex_package: VertexPackage,
   render_pipeline: RenderPipeline,
}
impl RaymarchingPipeline {
   pub fn new(setup: &Setup, raymarching_package: &RaymarchingPackage, refresh_counter: i32) -> Self {
      let vertex_package = VertexPackage::new(&setup.device, SQUARE_VERTICES, SQUARE_INDICES);

      let render_pipeline_layout = setup.device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
         label: Some("Render Pipeline Layout"),
         bind_group_layouts: &[
            &raymarching_package.constants.layout,
         ],
         push_constant_ranges: &[],
      });


      println!("\n//////////////////////////////////\nNo: {}", refresh_counter);

      compile_shader("src/bundles/raymarching_bundle/shaders/vertex.glsl", "src/bundles/raymarching_bundle/shaders/spv/vertex.spv", "vertex");
      let vert = load_spv_shader(&setup, Box::from(Path::new("src/bundles/raymarching_bundle/shaders/spv/vertex.spv")));

      compile_shader("src/bundles/raymarching_bundle/shaders/fragment.glsl", "src/bundles/raymarching_bundle/shaders/spv/fragment.spv", "fragment");
      let frag = load_spv_shader(&setup, Box::from(Path::new("src/bundles/raymarching_bundle/shaders/spv/fragment.spv")));



      let render_pipeline = setup.device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
         label: Some("Render Pipeline"),
         layout: Some(&render_pipeline_layout),

         vertex: wgpu::VertexState {
            module: &vert,
            entry_point: "main", // 1.
            buffers: &[
               Vertex::desc(),
            ], // 2.
         },

         fragment: Some(wgpu::FragmentState { // 3.
            module: &frag,
            entry_point: "main",
            targets: &[Some(wgpu::ColorTargetState { // 4.
               format: setup.config.format,
               blend: Some(wgpu::BlendState::REPLACE),
               write_mask: wgpu::ColorWrites::ALL,
            })],
         }),

         primitive: wgpu::PrimitiveState {
            topology: wgpu::PrimitiveTopology::TriangleList, // 1.
            strip_index_format: None,
            front_face: wgpu::FrontFace::Ccw, // 2.
            cull_mode: Some(wgpu::Face::Back),
            // Setting this to anything other than Fill requires Features::NON_FILL_POLYGON_MODE
            polygon_mode: wgpu::PolygonMode::Fill,
            // Requires Features::DEPTH_CLIP_CONTROL
            unclipped_depth: false,
            // Requires Features::CONSERVATIVE_RASTERIZATION
            conservative: false,
         },

         depth_stencil: None, // 1.
         multisample: wgpu::MultisampleState {
            count: 1, // 2.
            mask: !0, // 3. returns a bit array of all ones to select all possible masks 0x1111...
            alpha_to_coverage_enabled: false, // 4.
         },

         multiview: None, // 5.
      });

      Self {
         vertex_package,
         render_pipeline,
      }
   }

   pub fn render_pass(&self, encoder: &mut CommandEncoder, view: &TextureView, raymarching_package: &RaymarchingPackage) {
      let mut render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
         label: Some("Render Pass"),
         color_attachments: &[
            // This is what @location(0) in the fragment shader targets
            Some(wgpu::RenderPassColorAttachment {
               view: &view,
               resolve_target: None,
               ops: wgpu::Operations {
                  load: wgpu::LoadOp::Clear(Color {
                     r: 0.1,
                     g: 0.1,
                     b: 0.1,
                     a: 1.0,
                  }),
                  store: wgpu::StoreOp::Store,
               }
            })
         ],
         depth_stencil_attachment: None,
         occlusion_query_set: None,
         timestamp_writes: None,
      });

      render_pass.set_pipeline(&self.render_pipeline);

      // bind groups
      render_pass.set_bind_group(0, &raymarching_package.constants.bind_group, &[]);


      render_pass.set_vertex_buffer(0, self.vertex_package.vertex_buffer.slice(..));
      render_pass.set_index_buffer(self.vertex_package.index_buffer.slice(..), IndexFormat::Uint16);

      render_pass.draw_indexed(0..self.vertex_package.num_indices, 0, 0..1);
   }
}

fn load_spv_shader(setup: &Setup, path: Box<Path>) -> ShaderModule {
   let shader_code = fs::read(path).expect("Failed to read shader file");
   let shader_code_u32_slice = bytemuck::cast_slice(&shader_code);

   let dsec = ShaderModuleDescriptor {
      label: None,
      source: ShaderSource::SpirV(Cow::Borrowed(shader_code_u32_slice)),
   };

   return setup.device.create_shader_module(dsec);
}

fn compile_shader(from: &str, to: &str, stage: &str) {
   let mut child = Command::new("src/utility/glslc.exe")
       .arg(format!("-fshader-stage={}", stage))
       .arg(from)
       .arg("-o")
       .arg(to)
       .spawn()
       .expect("idk somethings fucked");

   let encode = child.wait()
       .expect("Failed to wait on glslc command");

   if encode.success() {
      println!("Shader {stage} compiled successfully.\n");
   } else {
      eprintln!("Shader {stage} compilation failed.\n");
   }
}
