use egui::{Ui};
use wgpu::ShaderStages;
use crate::{defaults_and_sliders_gui, defaults_only_gui};
use crate::inbuilt::setup::Setup;
use crate::packages::time_package::TimePackage;
use crate::utility::structs::UniformPackageSingles;

pub struct RaymarchingPackage {
   pub constants: UniformPackageSingles<Constants>,
   pub settings: UniformPackageSingles<Settings>,
}
impl RaymarchingPackage {
   pub fn new(setup: &Setup) -> Self {

      let constants = UniformPackageSingles::<Constants>::create(setup, ShaderStages::FRAGMENT, Constants::default());
      let settings = UniformPackageSingles::<Settings>::create(setup, ShaderStages::FRAGMENT, Settings::default());

      Self {
         constants,
         settings,
      }
   }

   pub fn gui(&mut self, ui: &mut Ui) {
      self.constants.data.ui(ui);
      self.settings.data.ui(ui);
   }

   pub fn update(&mut self, setup: &Setup, time_package: &TimePackage) {
      let data = &mut self.constants.data;

      data.time = time_package.start_time.elapsed().as_secs_f32();
      data.aspect = setup.size.width as f32 / setup.size.height as f32;

      self.constants.update_with_data(&setup.queue);
      self.settings.update_with_data(&setup.queue);
   }
}

defaults_only_gui!(
   Constants,
   aspect: f32 = 0.0,
   time: f32 = 0.0
);

defaults_and_sliders_gui!(
   Settings,
   main_steps: i32 = 80 => 0..=300,
   reflect_steps: i32 = 80 => 0..=300,


   farplane: f32 = 100.0 => 0.0..=500.0,
   fov: f32 = 1.0 => 0.1..=2.0,

   p: f32 = 0.0 => -10.0..=10.0,
   pp: f32 = 0.0 => -10.0..=10.0,
   ppp: f32 = 0.0 => -10.0..=10.0,
   pppp: f32 = 0.0 => -10.0..=10.0,
   ppppp: f32 = 0.0 => -10.0..=10.0,
   ppppppp: f32 = 0.0 => -10.0..=10.0,
   pppppppp: f32 = 0.0 => -10.0..=10.0,
   ppppppppp: f32 = 0.0 => -10.0..=10.0




);