use eframe::{
    egui, epaint::{ColorImage, Color32}
};
use egui_extras::RetainedImage;
use std::{fmt, path};

const PICTURE_PATH_1: &str = "TestPictures/Lena.png";
const PICTURE_PATH_2: &str = "TestPictures/Bunny_2.jpg";


const PICTURE_PATH: &str = PICTURE_PATH_1;

enum ViewState {
    SourceImage,
    Wavelet_1,
    Wavelet_2,
}

impl fmt::Display for ViewState {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            ViewState::SourceImage => write!(f, "Source image"),
            ViewState::Wavelet_1 => write!(f, "Wavelet 1 stage"),
            ViewState::Wavelet_2 => write!(f, "Wavelet 2 stage"),
        }
    }
}

#[derive(PartialEq, Clone)]
struct GrayscaleImage {
    data: ColorImage
}

impl GrayscaleImage {
    fn new(source_image: &ColorImage) -> Self {
        let mut data = ColorImage::new(source_image.size, Color32::BLACK);
        for y in 0..source_image.height() {
            for x in 0..source_image.width() {
                let i = y * source_image.width() + x;

                let gray_level = compute_pixel_brightness(source_image.pixels[i]);

                data.pixels[i] = Color32::from_gray(gray_level);
            }
        }
        Self { data, }
    }
}

fn compute_pixel_brightness(pixel: Color32) -> u8 {
    let red = pixel.r() as f32;
    let green = pixel.g() as f32;
    let blue = pixel.b() as f32;

    let result = 0.3*red + 0.59*green + 0.11*blue;

    if result > u8::MAX as f32 {
        u8::MAX
    }
    else{ result.round() as u8}
}

fn find_wavelet_transform(image: GrayscaleImage) -> GrayscaleImage{

    let mut result = GrayscaleImage::new(&ColorImage::new(image.data.size, Color32::BLACK));

   
    for y in 0..image.data.height() {
        for x in (0..image.data.width()-1).step_by(2) {
            let i = y * image.data.width() + x;
            let result_i = y * image.data.width() + x/2;
            result.data.pixels[result_i] = Color32::from_gray(((image.data.pixels[i].r() as f32 + image.data.pixels[i+1].r() as f32)/1.41) as u8);
        }
    }

    for y in 0..image.data.height() {
        for x in (0..image.data.width()-1).step_by(2) {
            let i = y * image.data.width() + x;
            let result_i = y * image.data.width() + x/2 + image.data.width()/2;
            result.data.pixels[result_i] = Color32::from_gray(((image.data.pixels[i].r() as f32 - image.data.pixels[i+1].r() as f32)/1.41) as u8);
        }
    }
    
    let mut result_2 = GrayscaleImage::new(&ColorImage::new(image.data.size, Color32::BLACK));

    for y in 0..image.data.height() {
        for x in 0..image.data.width() {
            let i = y * image.data.width() + x;
            let j = x * image.data.width() + y;
           
            result_2.data.pixels[j] = result.data.pixels[i];
        }
    }


    for y in 0..image.data.height() {
        for x in (0..image.data.width()-1).step_by(2) {
            let i = y * image.data.width() + x;
            let result_i = y * image.data.width() + x/2;
            result.data.pixels[result_i] = Color32::from_gray(((result_2.data.pixels[i].r() as f32 + result_2.data.pixels[i+1].r() as f32)/1.41) as u8);
        }
    }

    for y in 0..image.data.height() {
        for x in (0..image.data.width()-1).step_by(2) {
            let i = y * image.data.width() + x;
            let result_i = y * image.data.width() + x/2 + image.data.width()/2;
            result.data.pixels[result_i] = Color32::from_gray(((result_2.data.pixels[i].r() as f32 - result_2.data.pixels[i+1].r() as f32)/1.41) as u8);
        }
    }

    for y in 0..image.data.height() {
        for x in 0..image.data.width() {
            let i = y * image.data.width() + x;
            let j = x * image.data.width() + y;
           
            result_2.data.pixels[j] = result.data.pixels[i];
        }
    }

    result_2
}

fn make_obrezok(image: &GrayscaleImage) -> GrayscaleImage{
 
    let array = [image.data.size[0]/2,image.data.size[1]/2];
    let mut result = GrayscaleImage::new(&ColorImage::new(array, Color32::BLACK));

    for y in 0..image.data.height()/2 {
        for x in 0..image.data.width()/2 {
            let i = y * image.data.width()/2 + x;
            let j = y * image.data.width() + x;

            result.data.pixels[i] = image.data.pixels[j];
        }
    }

    result
}

struct Application {
    state: ViewState,

    source_image: ColorImage,
    wavelet_1: GrayscaleImage,
    wavelet_2: GrayscaleImage,
}

impl Default for Application {
    fn default() -> Self {
        let source_image = load_image_from_path(path::Path::new(PICTURE_PATH)).unwrap();

        let wavelet_1 = find_wavelet_transform(GrayscaleImage::new(&source_image));

        let wavelet_2 = find_wavelet_transform(GrayscaleImage::new(&make_obrezok(&wavelet_1).data));

        Self {
            state: ViewState::SourceImage,

            source_image,
            wavelet_1,
            wavelet_2,
        }
    }
}

impl eframe::App for Application {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            ui.vertical_centered_justified(|ui| {
                if ui.button("<-").clicked() {
                    self.state = match self.state {
                        ViewState::SourceImage => ViewState::Wavelet_2,
                        ViewState::Wavelet_1 => ViewState::SourceImage,
                        ViewState::Wavelet_2 => ViewState::Wavelet_1,   
                    };
                }
                if ui.button("->").clicked() {
                    self.state = match self.state {
                        ViewState::SourceImage => ViewState::Wavelet_1,
                        ViewState::Wavelet_1 => ViewState::Wavelet_2,
                        ViewState::Wavelet_2 => ViewState::SourceImage,
                    };
                }
            });

            ui.vertical(|ui| {
                ui.heading(format!("{}", self.state));
                ui.horizontal(|ui| {
                    let (name, image) = match self.state {
                        ViewState::SourceImage => (
                            "Source image",
                            self.source_image.clone(),
                        ),
                        ViewState::Wavelet_1 => (
                            "Wavelet 1 stage",
                            self.wavelet_1.data.clone(),

                        ),
                        ViewState::Wavelet_2 => (
                            "Wavelet 2 stage",
                            self.wavelet_2.data.clone(),

                        )
                    };
                    RetainedImage::from_color_image(name, image).show(ui);
                });
            });
        });
    }
}

fn load_image_from_path(path: &path::Path) -> Result<egui::ColorImage, image::ImageError> {
    let image = image::io::Reader::open(path)?.decode()?;
    let size = [image.width() as _, image.height() as _];
    let image_buffer = image.to_rgba8();
    let pixels = image_buffer.as_flat_samples();
    Ok(egui::ColorImage::from_rgba_unmultiplied(
        size,
        pixels.as_slice(),
    ))
}

fn main() -> eframe::Result<()> {
    let options = eframe::NativeOptions {
        initial_window_size: Option::from(egui::Vec2::new(1000f32, 700f32)),
        ..Default::default()
    };
    eframe::run_native(
        "Image processing",
        options,
        Box::new(|_cc| Box::<Application>::default()),
    )
}