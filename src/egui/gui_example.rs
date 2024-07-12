use egui::{Ui};
use crate::packages::time_package::TimePackage;

pub fn gui(
   ui: &mut Ui,
   time_package: &TimePackage,
) {
   ui.add(egui::Label::new(format!("FPS: {}", time_package.fps)));

   let mut test = 23.0;
   ui.add(egui::Slider::new(&mut test, 0.1..=1.0).text("test"));

   ui.end_row();
}