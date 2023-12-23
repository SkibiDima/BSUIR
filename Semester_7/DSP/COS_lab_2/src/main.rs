use eframe::{
    egui,
    egui::{plot::BarChart, widgets::plot},
    epaint::{Color32, ColorImage},
};
use egui_extras::RetainedImage;
use float_eq::{assert_float_eq, float_eq};
use std::{fmt, path};

const PICTURE_PATH_L11: &str = "TestPictures/lvl_1/P0001460.jpg";
const PICTURE_PATH_L12: &str = "TestPictures/lvl_1/P0001461.jpg";
const PICTURE_PATH_L13: &str = "TestPictures/lvl_1/P0001467.jpg";
const PICTURE_PATH_L14: &str = "TestPictures/lvl_1/P0001468.jpg";
const PICTURE_PATH_L21: &str = "TestPictures/lvl_2/P0001469.jpg";
const PICTURE_PATH_L22: &str = "TestPictures/lvl_2/P0001471.jpg";
const PICTURE_PATH_L31: &str = "TestPictures/lvl_3/P0001464.jpg";
const PICTURE_PATH_L32: &str = "TestPictures/lvl_3/P0001465.jpg";
const PICTURE_PATH_L33: &str = "TestPictures/lvl_3/P0001470.jpg";
const PICTURE_PATH_L34: &str = "TestPictures/lvl_3/P0001472.jpg";

const PICTURE_PATH: &str = PICTURE_PATH_L33;

enum ViewState {
    SourceImage,
    Binarized,
    CleanBinarized,
    ObjectDots,
}

impl fmt::Display for ViewState {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            ViewState::SourceImage => write!(f, "source image"),
            ViewState::Binarized => write!(f, "binarized"),
            ViewState::CleanBinarized => write!(f, "clean binarized"),
            ViewState::ObjectDots => write!(f, "objects"),
        }
    }
}

struct ConvolutionKernel {
    coefficient: [usize; 9],
    divider: usize,
}

impl Default for ConvolutionKernel {
    fn default() -> Self {
        Self {
            coefficient: [1; 9],
            divider: 9,
        }
    }
}

#[derive(Debug, PartialEq, Clone)]
struct ObjectInformation {
    all_coord: Vec<(u32, u32)>,
    edges_coord: Vec<(u32, u32)>,
    area: f32,
    mass_center: (f32, f32),
    perimeter: f32,
    central_moment: f32,
    compactness: f32,
    elongation: f32,
    theta: f32,
}

impl ObjectInformation {
    fn compute_info(self) -> Self {
        let area: f32 = self.all_coord.len() as f32;
        let mass_center: (u32, u32) = self
            .all_coord
            .iter()
            .fold((0, 0), |acc, e| (acc.0 + e.0, acc.1 + e.1));
        let x = mass_center.0 as f32 / area as f32;
        let y = mass_center.1 as f32 / area as f32;
        let perimeter = self.edges_coord.len() as f32;
        let copmactness: f32 = (perimeter * perimeter / area) as f32;

        let m20: f32 = self
            .all_coord
            .iter()
            .fold(0.0, |acc, e| acc + (e.0 as f32 - x).powi(2));
        let m02: f32 = self
            .all_coord
            .iter()
            .fold(0.0, |acc, e| acc + (e.1 as f32 - y).powi(2));
        let m11: f32 = self
            .all_coord
            .iter()
            .fold(0.0, |acc, e| acc + (e.0 as f32 - x)*(e.1 as f32 - y));

        let central_moment: f32 = m11;

        let elongation: f32 =
            (m20 + m02 + f32::sqrt(f32::powi(m20 - m02, 2) + 4.0 * f32::powi(m11, 2)))
                / (m20 + m02 - f32::sqrt(f32::powi(m20 - m02, 2) + 4.0 * f32::powi(m11, 2)));

        let theta: f32 = 0.5 * f32::atan((2.0 * m11) / (m20 - m02));

        Self {
            all_coord: self.all_coord,
            edges_coord: self.edges_coord,
            area: area,
            mass_center: (x, y),
            perimeter,
            central_moment,
            compactness: copmactness,
            elongation,
            theta,
        }
    }
}

impl Default for ObjectInformation {
    fn default() -> Self {
        Self {
            all_coord: Vec::new(),
            edges_coord: Vec::new(),
            area: 0.0,
            perimeter: 0.0,
            mass_center: (0.0, 0.0),
            central_moment: 0.0,
            compactness: 0.0,
            elongation: 0.0,
            theta: 0.0,
        }
    }
}

trait ImageOperations {
    fn compute_pixel_brightness(pixel: Color32) -> u8;

    fn compute_brightness(image: &ColorImage) -> Brightness {
        let mut result = Brightness::default();
        for y in 0..image.height() {
            for x in 0..image.width() {
                let i = y * image.width() + x;

                let brightness = Self::compute_pixel_brightness(image.pixels[i]);
                if result.max < brightness {
                    result.max = brightness;
                } else if result.min > brightness {
                    result.min = brightness;
                }
            }
        }
        result
    }

    fn find_threshold(image: &ColorImage) -> u8 {
        let mut bar_chart: [usize; (u8::MAX as usize) + 1] = [0; (u8::MAX as usize) + 1];
        for y in 0..image.height() {
            for x in 0..image.width() {
                let i = y * image.width() + x;

                bar_chart[Self::compute_pixel_brightness(image.pixels[i]) as usize] += 1;
            }
        }

        let mut first_half_index_max = 0;
        for i in 0..bar_chart.len() / 2 as usize {
            if bar_chart[i] > bar_chart[first_half_index_max] {
                first_half_index_max = i;
            }
        }
        let mut second_half_index_max = 0;
        for i in bar_chart.len() / 2..bar_chart.len() as usize {
            if bar_chart[i] > bar_chart[second_half_index_max] {
                second_half_index_max = i;
            }
        }
        ((first_half_index_max + second_half_index_max) / 2) as u8
    }

    fn find_bar_chart(image: &ColorImage) -> Vec<plot::Bar> {
        let mut bar_chart: [usize; (u8::MAX as usize) + 1] = [0; (u8::MAX as usize) + 1];
        for y in 0..image.height() {
            for x in 0..image.width() {
                let i = y * image.width() + x;

                bar_chart[Self::compute_pixel_brightness(image.pixels[i]) as usize] += 1;
            }
        }
        bar_chart
            .iter()
            .enumerate()
            .map(|(x, y)| plot::Bar::new(x as f64, *y as f64))
            .collect()
    }

    fn low_pass_filter_for_pixel_component(
        image: &ColorImage,
        target_x: usize,
        target_y: usize,
        kernel: &ConvolutionKernel,
        color_component_index: usize,
    ) -> u8 {
        let mut accumulator: usize = 0;
        for y in 0..3 {
            for x in 0..3 {
                let i = (y + target_y - 1) * image.width() + (x + target_x - 1);
                let kernel_index = y * 3 + x;
                accumulator += (image.pixels[i][color_component_index] as usize)
                    * kernel.coefficient[kernel_index];
            }
        }
        let result = accumulator / kernel.divider;
        if result > (u8::MAX as usize) {
            u8::MAX
        } else {
            result as u8
        }
    }

    fn compute_low_pass_filter(image: &ColorImage) -> ColorImage {
        let mut result = ColorImage::new(image.size, Color32::BLACK);
        let kernel = ConvolutionKernel::default();
        for y in 1..image.height() - 1 {
            for x in 1..image.width() - 1 {
                let i = y * image.width() + x;
                for color_component in 0..3 {
                    let target_color_component = Self::low_pass_filter_for_pixel_component(
                        image,
                        x,
                        y,
                        &kernel,
                        color_component,
                    );
                    result.pixels[i][color_component] = target_color_component;
                }
            }
        }
        result
    }

    fn compute_four_connected(image: &ColorImage) -> ColorImage {
        let mut result = ColorImage::new(image.size, Color32::BLACK);
        for y in 1..image.height() - 1 {
            for x in 1..image.width() - 1 {
                let i = y * image.width() + x;
                if image.pixels[i] == Color32::WHITE
                    && image.pixels[i - 1] == Color32::WHITE
                    && image.pixels[i + 1] == Color32::WHITE
                    && image.pixels[i - image.width()] == Color32::WHITE
                    && image.pixels[i + image.width()] == Color32::WHITE
                {
                    result.pixels[i] = Color32::WHITE;
                    result.pixels[i - 1] = Color32::WHITE;
                    result.pixels[i + 1] = Color32::WHITE;
                    result.pixels[i - image.width()] = Color32::WHITE;
                    result.pixels[i + image.width()] = Color32::WHITE;
                }
            }
        }

        result
    }

    fn compute_erosion(image: &ColorImage) -> ColorImage {
        let mut result = ColorImage::new(image.size, Color32::BLACK);
        for y in 1..image.height() - 1 {
            for x in 1..image.width() - 1 {
                let i = y * image.width() + x;
                if image.pixels[i] == Color32::WHITE
                    && image.pixels[i - 1] == Color32::WHITE
                    && image.pixels[i + 1] == Color32::WHITE
                    && image.pixels[i - image.width()] == Color32::WHITE
                    && image.pixels[i + image.width()] == Color32::WHITE
                {
                    result.pixels[i] = Color32::WHITE;
                }
            }
        }

        result
    }

    fn compute_building(image: &ColorImage) -> ColorImage {
        let mut result = ColorImage::new(image.size, Color32::BLACK);
        for y in 1..image.height() - 1 {
            for x in 1..image.width() - 1 {
                let i = y * image.width() + x;
                if image.pixels[i] == Color32::WHITE {
                    result.pixels[i] = Color32::WHITE;
                    result.pixels[i - 1] = Color32::WHITE;
                    result.pixels[i + 1] = Color32::WHITE;
                    result.pixels[i - image.width()] = Color32::WHITE;
                    result.pixels[i + image.width()] = Color32::WHITE;
                }
            }
        }

        result
    }

    fn compute_clean_image(image: &ColorImage) -> ColorImage {
        let mut result = image.clone();

        for _i in 0..3 {
            result = Self::compute_erosion(&result);
        }
        result = Self::compute_low_pass_filter(&result);
        for _i in 0..4 {
            result = Self::compute_building(&result);
        }

        result
    }

    fn find_objects(image: &ColorImage) -> Vec<ObjectInformation> {
        let mut objects: Vec<ObjectInformation> = Vec::new();
        let mut temp_image = image.clone();

        for y in 0..image.height() {
            for x in 0..image.width() {
                let i = y * image.width() + x;
                if temp_image.pixels[i] == Color32::WHITE {
                    let mut temp_object: ObjectInformation = ObjectInformation::default();
                    Self::find_object_pixels_recur(&mut temp_image, x, y, &mut temp_object);

                    objects.push(temp_object.compute_info());
                }
            }
        }

        objects
    }

    fn find_object_pixels_recur(
        temp_image: &mut ColorImage,
        x: usize,
        y: usize,
        object: &mut ObjectInformation,
    ) {
        let i = y * temp_image.width() + x;
        if temp_image.pixels[i] == Color32::BLACK {
            return;
        } 
        else if temp_image.pixels[i] == Color32::GRAY{ return;}
        else {
            if temp_image.pixels[i] == Color32::WHITE
                && (temp_image.pixels[i - 1] == Color32::WHITE || temp_image.pixels[i - 1] == Color32::GRAY)
                && (temp_image.pixels[i + 1] == Color32::WHITE || temp_image.pixels[i + 1] == Color32::GRAY)
                && (temp_image.pixels[i - temp_image.width()] == Color32::WHITE || temp_image.pixels[i - temp_image.width()] == Color32::GRAY)
                && (temp_image.pixels[i + temp_image.width()] == Color32::WHITE || temp_image.pixels[i + temp_image.width()] == Color32::GRAY)
            {
                object.all_coord.push((x as u32, y as u32));
            } else {
                object.all_coord.push((x as u32, y as u32));
                object.edges_coord.push((x as u32, y as u32));
            }
            temp_image.pixels[i] = Color32::GRAY;
            if x < temp_image.width() {
                Self::find_object_pixels_recur(temp_image, x + 1, y, object);
            }
            if x > 0 {
                Self::find_object_pixels_recur(temp_image, x - 1, y, object);
            }
            if y < temp_image.height() {
                Self::find_object_pixels_recur(temp_image, x, y + 1, object);
            }
            if y > 0 {
                Self::find_object_pixels_recur(temp_image, x, y - 1, object);
            }
        }
    }

    fn clusterization(image: &ColorImage, objects: Vec<ObjectInformation>) -> ColorImage {
        let mut result = ColorImage::new(image.size, Color32::BLACK);

        let mut clusters = (
            (*objects.last().unwrap()).clone(),
            (*objects.first().unwrap()).clone(),
            (objects[(objects.len() / 2) as usize]).clone(),
        );

        let mut clustered_objects: Vec<(&ObjectInformation, u8)> = Vec::new();
        let mut i = 0;
        loop {
            let prev_clusters = clusters.clone();
            let areas = (clusters.0.area, clusters.1.area, clusters.2.area);
            let perimeters = (
                clusters.0.perimeter,
                clusters.1.perimeter,
                clusters.2.perimeter,
            );
            let elongations = (
                clusters.0.elongation,
                clusters.1.elongation,
                clusters.2.elongation,
            );
            clustered_objects.clear();
            for object in &objects {
                let cluster_number: u8;
                let distance_0 = f32::sqrt(
                    (f32::powi(object.area.max(areas.0) - object.area.min(areas.0), 2)
                        + f32::powi(
                            object.perimeter.max(perimeters.0) - object.perimeter.min(perimeters.0),
                            2,
                        )
                        + f32::powi(
                            object.elongation.max(elongations.0)
                                - object.elongation.min(elongations.0),
                            2,
                        )) as f32,
                );

                let distance_1 = f32::sqrt(
                    (f32::powi(object.area.max(areas.1) - object.area.min(areas.1), 2)
                        + f32::powi(
                            object.perimeter.max(perimeters.1) - object.perimeter.min(perimeters.1),
                            2,
                        )
                        + f32::powi(
                            object.elongation.max(elongations.1)
                                - object.elongation.min(elongations.1),
                            2,
                        )) as f32,
                );

                let distance_2 = f32::sqrt(
                    (f32::powi(object.area.max(areas.2) - object.area.min(areas.2), 2)
                        + f32::powi(
                            object.perimeter.max(perimeters.2) - object.perimeter.min(perimeters.2),
                            2,
                        )
                        + f32::powi(
                            object.elongation.max(elongations.2)
                                - object.elongation.min(elongations.2),
                            2,
                        )) as f32,
                );

                if distance_0 < distance_1 && distance_0 < distance_2 {
                    cluster_number = 0;
                } else if distance_1 < distance_0 && distance_1 < distance_2 {
                    cluster_number = 1;
                } else {
                    cluster_number = 2;
                }

                clustered_objects.push((object, cluster_number));
            }

            let mut new_areas = (0.0, 0.0, 0.0);
            let mut new_perimeters = (0.0, 0.0, 0.0);
            let mut new_elongations = (0.0, 0.0, 0.0);
            let mut cluster_0_len = 1.0;
            let mut cluster_1_len = 1.0;
            let mut cluster_2_len = 1.0;
            for object in &clustered_objects {
                if object.1 == 0 {
                    new_areas.0 += object.0.area;
                    new_perimeters.0 += object.0.perimeter;
                    new_elongations.0 += object.0.elongation;
                    cluster_0_len += 1.0;
                }
                if object.1 == 1 {
                    new_areas.1 += object.0.area;
                    new_perimeters.1 += object.0.perimeter;
                    new_elongations.1 += object.0.elongation;
                    cluster_1_len += 1.0;
                }
                if object.1 == 2 {
                    new_areas.2 += object.0.area;
                    new_perimeters.2 += object.0.perimeter;
                    new_elongations.2 += object.0.elongation;
                    cluster_2_len += 1.0;
                }
            }
            
            //if float_eq!(cluster_0_len, 0.0, abs <= 0.000_1){0.0} else {}
            new_areas = (
                new_areas.0 / cluster_0_len,
                new_areas.1 / cluster_1_len,
                new_areas.2 / cluster_2_len,
            );
            new_perimeters = (
                new_perimeters.0 / cluster_0_len,
                new_perimeters.1 / cluster_1_len,
                new_perimeters.2 / cluster_2_len,
            );
            new_elongations = (
                new_elongations.0 / cluster_0_len,
                new_elongations.1 / cluster_1_len,
                new_elongations.2 / cluster_2_len,
            );

            if  i == 20 {
                break;
            }

            if float_eq!(prev_clusters.0.area, new_areas.0, abs <= 0.000_1)
                && float_eq!(prev_clusters.0.perimeter, new_perimeters.0, abs <= 0.000_1)
                && float_eq!(
                    prev_clusters.0.elongation,
                    new_elongations.0,
                    abs <= 0.000_1
                )
                && float_eq!(prev_clusters.1.area, new_areas.1, abs <= 0.000_1)
                && float_eq!(prev_clusters.1.perimeter, new_perimeters.1, abs <= 0.000_1)
                && float_eq!(
                    prev_clusters.1.elongation,
                    new_elongations.1,
                    abs <= 0.000_1
                )
                && float_eq!(prev_clusters.2.area, new_areas.2, abs <= 0.000_1)
                && float_eq!(prev_clusters.2.perimeter, new_perimeters.2, abs <= 0.000_1)
                && float_eq!(
                    prev_clusters.2.elongation,
                    new_elongations.2,
                    abs <= 0.000_1
                )
            {
                break;
            } else {
                clusters.0.area = new_areas.0;
                clusters.0.perimeter = new_perimeters.0;
                clusters.0.elongation = new_elongations.0;
                clusters.1.area = new_areas.1;
                clusters.1.perimeter = new_perimeters.1;
                clusters.1.elongation = new_elongations.1;
                clusters.2.area = new_areas.2;
                clusters.2.perimeter = new_perimeters.2;
                clusters.2.elongation = new_elongations.2;
            }
            i += 1;
        }

        for object in clustered_objects {
            let color: Color32;
            if object.1 == 0 {
                color = Color32::RED;
            } else if object.1 == 1 {
                color = Color32::GREEN;
            } else {
                color = Color32::BLUE;
            }
            for coord in &object.0.all_coord {
                let i = coord.1 * (result.width() as u32) + coord.0;
                result.pixels[i as usize] = color;
            }
            println!(
                "area {}, perimeter {}, elongation {}, cluster {}",
                object.0.area, object.0.perimeter, object.0.elongation, object.1
            );
        }

        result
    }
}

#[derive(Debug, PartialEq, Clone)]
struct Brightness {
    min: u8,
    max: u8,
}

impl Default for Brightness {
    fn default() -> Self {
        Self { min: 0, max: 255 }
    }
}

struct ColoredImage {
    data: ColorImage,
    //brightness: Brightness,
    bar_chart: Vec<plot::Bar>,
}

impl ImageOperations for ColoredImage {
    fn compute_pixel_brightness(pixel: Color32) -> u8 {
        let red = pixel.r() as f32;
        let green = pixel.g() as f32;
        let blue = pixel.b() as f32;

        let result = 0.3 * red + 0.59 * green + 0.11 * blue;

        if result > (u8::MAX as f32) {
            u8::MAX
        } else {
            result.round() as u8
        }
    }
}

impl ColoredImage {
    fn new(data: ColorImage) -> Self {
        //let brightness = Self::compute_brightness(&data);
        let bar_chart = Self::find_bar_chart(&data);
        Self {
            data,
            //brightness,
            bar_chart,
        }
    }
}

struct BinarizedImage {
    data: ColorImage,
    //brightness: Brightness,
    bar_chart: Vec<plot::Bar>,
}

impl ImageOperations for BinarizedImage {
    fn compute_pixel_brightness(pixel: Color32) -> u8 {
        let red = pixel.r();
        let green = pixel.g();
        let blue = pixel.b();
        if red != green && green != blue {
            panic!("pixel not gray: RGB[{red},{green},{blue}]");
        }
        red
    }
}

impl BinarizedImage {
    fn new(source_image: &ColorImage) -> Self {
        let mut data = ColorImage::new(source_image.size, Color32::BLACK);
        let threshold = ColoredImage::find_threshold(source_image);
        for y in 0..source_image.height() {
            for x in 0..source_image.width() {
                let i = y * source_image.width() + x;

                let mut gray_level = ColoredImage::compute_pixel_brightness(source_image.pixels[i]);
                if gray_level > threshold {
                    gray_level = 255;
                } else {
                    gray_level = 0
                };
                data.pixels[i] = Color32::from_gray(gray_level);
            }
        }
        //let brightness = Self::compute_brightness(&data);
        let bar_chart = Self::find_bar_chart(&data);
        Self {
            data,
            //brightness,
            bar_chart,
        }
    }
}

struct Application {
    state: ViewState,

    source_image: ColoredImage,
    binarized: BinarizedImage,
    clean_binarized: BinarizedImage,

    objects_image: ColoredImage,
}

impl Default for Application {
    fn default() -> Self {
        let source_image =
            ColoredImage::new(load_image_from_path(path::Path::new(PICTURE_PATH)).unwrap());

        let binarized = BinarizedImage::new(&source_image.data);

        let clean_binarized: BinarizedImage =
            BinarizedImage::new(&BinarizedImage::compute_clean_image(&binarized.data));

        let object_vector = ColoredImage::find_objects(&clean_binarized.data);

        let objects_image = ColoredImage::new(BinarizedImage::clusterization(
            &clean_binarized.data,
            object_vector,
        ));

        Self {
            state: ViewState::SourceImage,

            source_image,
            binarized,
            clean_binarized,

            objects_image,
        }
    }
}

impl eframe::App for Application {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            ui.vertical_centered_justified(|ui| {
                if ui.button("<-").clicked() {
                    self.state = match self.state {
                        ViewState::SourceImage => ViewState::ObjectDots,
                        ViewState::Binarized => ViewState::SourceImage,
                        ViewState::CleanBinarized => ViewState::Binarized,
                        ViewState::ObjectDots => ViewState::CleanBinarized,
                    };
                }
                if ui.button("->").clicked() {
                    self.state = match self.state {
                        ViewState::SourceImage => ViewState::Binarized,
                        ViewState::Binarized => ViewState::CleanBinarized,
                        ViewState::CleanBinarized => ViewState::ObjectDots,
                        ViewState::ObjectDots => ViewState::SourceImage,
                    };
                }
            });

            ui.vertical(|ui| {
                ui.heading(format!("{}", self.state));
                ui.horizontal(|ui| {
                    let (name, image, bar_chart) = match self.state {
                        ViewState::SourceImage => (
                            "source image",
                            self.source_image.data.clone(),
                            self.source_image.bar_chart.clone(),
                        ),
                        ViewState::Binarized => (
                            "binarized",
                            self.binarized.data.clone(),
                            self.binarized.bar_chart.clone(),
                        ),
                        ViewState::CleanBinarized => (
                            "clean binarized",
                            self.clean_binarized.data.clone(),
                            self.clean_binarized.bar_chart.clone(),
                        ),
                        ViewState::ObjectDots => (
                            "objects",
                            self.objects_image.data.clone(),
                            self.objects_image.bar_chart.clone(),
                        ),
                    };
                    RetainedImage::from_color_image(name, image).show(ui);
                    plot::Plot::new(name).show(ui, |plot_ui| {
                        plot_ui.bar_chart(BarChart::new(bar_chart));
                    });
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
