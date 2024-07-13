use egui::Ui;
use wgpu::{CommandEncoder, TextureView};
use winit::keyboard::KeyCode;
use crate::bundles::raymarching_bundle::raymarching_package::RaymarchingPackage;
use crate::bundles::raymarching_bundle::raymarching_pipeline::RaymarchingPipeline;
use crate::inbuilt::setup::Setup;
use crate::packages::input_manager_package::InputManager;
use crate::packages::time_package::TimePackage;

pub struct RaymarchingBundle {
   pub pipeline: RaymarchingPipeline,
   pub package: RaymarchingPackage,

   refresh_counter: i32,
}
impl RaymarchingBundle {
   pub fn new(setup: &Setup) -> Self {
      let package = RaymarchingPackage::new(setup);
      let pipeline = RaymarchingPipeline::new(setup, &package, 0);

      let refresh_counter = 0;

      Self {package, pipeline, refresh_counter}
   }

   pub fn update(&mut self, setup: &Setup, time_package: &TimePackage, input_manager: &InputManager) {
      self.package.update(setup, time_package);

      if input_manager.is_key_just_pressed(KeyCode::Space) {
         self.refresh_counter += 1;
         self.pipeline = RaymarchingPipeline::new(setup, &self.package, self.refresh_counter);
      }
   }

   pub fn gui(&mut self, ui: &mut Ui) {
      self.package.gui(ui);

   }

   pub fn render_pass(&self, encoder: &mut CommandEncoder, view: &TextureView) {
      self.pipeline.render_pass(encoder, view, &self.package);
   }
}

