use std::any::type_name;
use wgpu::{BindGroup, BindGroupDescriptor, BindGroupEntry, BindGroupLayout, BindGroupLayoutDescriptor, Buffer, BufferUsages, Queue, ShaderStages};
use wgpu::util::{BufferInitDescriptor, DeviceExt};
use crate::inbuilt::setup::Setup;

/// to Ping Or Pong
enum POP {
   First,
   Second,
}

pub struct PingPongData<T> {
   first: T,
   second: T,
   current: POP,
}
impl<T> PingPongData<T> {
   pub fn new(first: T, second: T) -> Self {
      Self {
         first,
         second,
         current: POP::First,
      }
   }

   pub fn pull_current(&self) -> &T {
      // send first
      match self.current {
         POP::First => { &self.first }
         POP::Second => { &self.second }
      }
   }

   pub fn pull_other(&self) -> &T {
      // send not first
      match self.current {
         POP::First => { &self.second }
         POP::Second => { & self.first }
      }
   }

   pub fn ping_pong(&mut self) {
      // swap
      self.current = match self.current {
         POP::First => { POP::Second }
         POP::Second => { POP::First }
      }
   }
}




pub struct UniformPackageSingles<T> {
   pub bind_group: BindGroup,
   pub layout: BindGroupLayout,
   pub buffer: Buffer,
   pub data: T,
}
impl<T: bytemuck::Pod> UniformPackageSingles<T> {
   // pre setups
   pub fn create(setup: &Setup, shader_stages: ShaderStages, data: T) -> UniformPackageSingles<T> {
      let buffer = setup.device.create_buffer_init(&BufferInitDescriptor {
         label: Some("screen aspect"),
         contents: bytemuck::bytes_of(&data),
         usage: BufferUsages::UNIFORM | BufferUsages::COPY_DST,
      });

      let layout = setup.device.create_bind_group_layout(&BindGroupLayoutDescriptor {
         label: Some("aspect_ratio_bind_group_layout"),
         entries: &[
            wgpu::BindGroupLayoutEntry {
               binding: 0,
               visibility: shader_stages,
               ty: wgpu::BindingType::Buffer {
                  ty: wgpu::BufferBindingType::Uniform,
                  has_dynamic_offset: false,
                  min_binding_size: wgpu::BufferSize::new(std::mem::size_of::<T>() as u64),
               },
               count: None,
            },
         ],
      });

      let bind_group = setup.device.create_bind_group(&BindGroupDescriptor {
         label: None,
         layout: &layout,
         entries: &[BindGroupEntry {
            binding: 0,
            resource: buffer.as_entire_binding()
         }],
      });

      UniformPackageSingles {
         bind_group,
         layout,
         buffer,
         data,
      }
   }

   // functions
   pub fn update_with_data(&self, queue: &Queue) {
      queue.write_buffer(
         &self.buffer,
         0,
         bytemuck::bytes_of(&self.data)
      );
   }

}