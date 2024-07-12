use wgpu::ShaderStages;
use crate::inbuilt::setup::Setup;
use crate::packages::time_package::TimePackage;
use crate::utility::structs::UniformPackageSingles;

pub struct RaymarchingPackage {
   pub constants: UniformPackageSingles<Constants>,
}
impl RaymarchingPackage {
   pub fn new(setup: &Setup) -> Self {

      let constants = UniformPackageSingles::<Constants>::create(setup, ShaderStages::FRAGMENT, Constants::default());

      Self {
         constants,
      }
   }

   pub fn update(&mut self, setup: &Setup, time_package: &TimePackage) {
      let data = &mut self.constants.data;

      data.time = time_package.start_time.elapsed().as_secs_f32();
      data.aspect = setup.size.width as f32 / setup.size.height as f32;

      self.constants.update_with_data(&setup.queue);
   }
}

#[repr(C)]
#[derive(Copy, Clone, Debug, bytemuck::Pod, bytemuck::Zeroable)]
pub struct Constants {
   pub aspect: f32,
   pub time: f32,
}
impl Default for Constants {
   fn default() -> Self {
      Self {
         aspect: 0.0,
         time: 0.0,
      }
   }
}