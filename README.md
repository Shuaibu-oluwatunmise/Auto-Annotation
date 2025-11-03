# Auto Annotation Tool for Object Detection

Automatically annotate images for object detection using Grounding DINO, with zero manual labeling required. Simply provide images organized by class, and get a YOLOv8-ready dataset.

## 🌟 Features

- **Zero-shot object detection** - No pre-trained models needed, just describe objects in plain English
- **Automatic annotation** - Processes multiple classes with Grounding DINO
- **Stratified dataset splitting** - Balanced 80/10/10 train/val/test split across all classes
- **YOLOv8 format** - Output ready for immediate training
- **Visualization tools** - Preview annotations with bounding boxes
- **Batch processing** - Handle multiple classes in one run

## 📋 Requirements

- Python 3.10-3.12 (Python 3.14 not yet fully supported)
- CPU or CUDA-compatible GPU (RTX 30XX series or older)
- Windows, Linux, or macOS

## 🚀 Installation

1. **Clone the repository:**
```bash
git clone <your-repo-url>
cd Auto_Annotation
```

2. **Create a virtual environment (recommended):**
```bash
python -m venv venv

# Windows
.\venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

3. **Install dependencies:**
```bash
pip install -r requirements.txt
```

## 📁 Project Structure
```
Auto_Annotation/
├── Auto_Annotate.py          # Main annotation script
├── visualize_yolo.py          # Visualization tool
├── requirements.txt           # Python dependencies
├── README.md                  # Documentation
├── images/                    # Input folder (create this)
│   ├── Mouse/                 # Class 1 images
│   ├── Keyboard/              # Class 2 images
│   ├── Mug/                   # Class 3 images
│   └── Printer/               # Class 4 images
└── YOLO_DATA/                 # Output folder (auto-generated)
    ├── train/
    ├── val/
    ├── test/
    └── data.yaml
```

## 🎯 Usage

### Step 1: Organize Your Images

Create an `images/` folder with subfolders for each class:
```
images/
├── Mouse/
│   ├── img1.jpg
│   ├── img2.jpg
│   └── ...
├── Keyboard/
│   ├── photo1.jpg
│   └── ...
└── ...
```

### Step 2: Configure Text Prompts

Edit `Auto_Annotate.py` and update the `prompt_mapping` dictionary:
```python
prompt_mapping = {
    "Mouse": "computer mouse",
    "Keyboard": "keyboard",
    "Mug": "coffee mug",
    "Printer": "printer",
    # Add more classes here
}
```

The keys should match your folder names, and values are the text prompts for Grounding DINO.

### Step 3: Run Auto-Annotation
```bash
python Auto_Annotate.py
```

**What happens:**
1. ✅ Renames all images with class prefixes (e.g., `Mouse0001.jpg`)
2. ✅ Generates class IDs automatically (0, 1, 2, 3...)
3. ✅ Annotates each class using Grounding DINO
4. ✅ Merges into unified dataset with 80/10/10 split
5. ✅ Creates YOLOv8-compatible `data.yaml`

**Output:** `YOLO_DATA/` folder ready for training!

### Step 4: Visualize Annotations (Optional)
```bash
python visualize_yolo.py
```

This creates a `visualizations/` folder with bounding boxes drawn on images. Each class gets a unique color for easy verification.

## 📊 Output Format

The `YOLO_DATA/` folder follows standard YOLOv8 format:
```
YOLO_DATA/
├── train/
│   ├── images/           # 80% of images (balanced across classes)
│   └── labels/           # Corresponding .txt annotation files
├── val/
│   ├── images/           # 10% of images
│   └── labels/
├── test/
│   ├── images/           # 10% of images
│   └── labels/
└── data.yaml             # Dataset configuration
```

### Label Format

Each `.txt` file contains one line per object:
```
class_id x_center y_center width height
```

All values are normalized (0-1).

## 🔧 Configuration Options

Edit these variables in `Auto_Annotate.py`:
```python
# Input/Output folders
input_folder = Path("./images")
output_folder = Path("YOLO_DATA")

# Dataset split ratios
train_split = 0.8
val_split = 0.1
test_split = 0.1

# Text prompts for each class
prompt_mapping = {
    "ClassName": "text description for Grounding DINO"
}
```

## 🐛 Troubleshooting

### CUDA Errors (RTX 40XX/50XX)

If you have a newer GPU (RTX 4000/5000 series), PyTorch may not support it yet. Force CPU mode:

**Windows:**
```bash
$env:CUDA_VISIBLE_DEVICES="-1"
python Auto_Annotate.py
```

**Linux/Mac:**
```bash
CUDA_VISIBLE_DEVICES=-1 python Auto_Annotate.py
```

Or add this to the top of `Auto_Annotate.py`:
```python
import os
os.environ['CUDA_VISIBLE_DEVICES'] = '-1'
```

### Slow Processing

- CPU mode is slow (~2-3 seconds per image)
- Consider using Google Colab with free GPU if you have many images
- Batch your images into smaller sets

### Empty Annotations

If annotations are empty or incorrect:
- Check your text prompts in `prompt_mapping`
- Try more descriptive prompts (e.g., "black computer mouse" instead of "mouse")
- Verify image quality (not too blurry or small)

## 📈 Training with YOLOv8

After annotation, train a YOLOv8 model:
```bash
pip install ultralytics

# Train
yolo detect train data=YOLO_DATA/data.yaml model=yolov8n.pt epochs=100 imgsz=640
```

## 🤝 Contributing

Contributions welcome! Please feel free to submit a Pull Request.

## 📝 License

MIT License - feel free to use for personal or commercial projects.

## 🙏 Acknowledgments

- [Grounding DINO](https://github.com/IDEA-Research/GroundingDINO) - Zero-shot object detection
- [Autodistill](https://github.com/autodistill/autodistill) - Auto-labeling framework
- [Ultralytics YOLOv8](https://github.com/ultralytics/ultralytics) - Object detection training

## 📧 Contact

For questions or issues, please open a GitHub issue.

---

**Happy Annotating! 🎯**